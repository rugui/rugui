module RuGUI
  #
  # Base class for all controllers.
  #
  class BaseController < BaseObject
    include RuGUI::PropertyObserver
    include RuGUI::LogSupport
    include RuGUI::SignalSupport
    include RuGUI::EntityRegistrationSupport

    attr_accessor :models
    attr_accessor :main_models
    attr_accessor :views
    attr_accessor :controllers
    attr_accessor :parent_controller

    def initialize(parent_controller = nil)
      @models = {}
      @main_models = {}
      @views = {}
      @controllers = {}

      if parent_controller.nil?
        @parent_controller = self
      else
        @parent_controller = parent_controller
      end

      register_all :model
      setup_models

      register_default_view if should_register_default_view?
      register_all :view
      setup_views

      register_all :controller
      setup_controllers

      register_all :main_model
      setup_main_models
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks

    # Returns the framework_adapter for this class.
    def framework_adapter
      framework_adapter_for('BaseController')
    end

    #
    # Registers a model for this controller.
    #
    # If the given model is a string or symbol, it will be camelized and
    # a new instance of the model class will be created.
    #
    def register_model(model, name = nil)
      register(:model, model, name)
    end

    #
    # Registers a main model for this controller.
    #
    # Only model names (as string or symbol) should be passed. Optionally a
    # different name may be given. If the main controller doesn't have a model
    # registered or if this is the main controller a NoMethodError exception
    # will be raised.
    #
    def register_main_model(model_name, name = nil)
      register(:main_model, model_name, name)
    end

    #
    # Registers a view for this controller.
    #
    # If the given view is a string or symbol, it will be camelized and a new
    # instance of the view class will be created.
    #
    def register_view(view, name = nil)
      register(:view, view, name)
    end

    #
    # Registers a child controller for this controller.
    #
    # If the given controller is a string or symbol, it will be camelized and
    # a new instance of the controller class will be created.
    #
    def register_controller(controller, name = nil)
      register(:controller, controller, name)
    end

    #
    # Called after the controller is registered in another one.
    #
    def post_registration
    end

    # Returns the main controller instance.
    #
    # This is an useful way to quickly access the main controller from any other
    # controller. Since applications may have only one main controller and it is
    # always the 'root' of the tree of controllers, this provides indirect
    # access to any other controller in the application.
    #
    # NOTE: The main controller is cached, so that subsequent calls are faster.
    def main_controller
      @main_controller ||= find_main_controller
    end

    class << self
      def models(*names)
        register(:model, *names)
      end

      def main_models(*names)
        register(:main_model, *names)
      end

      def views(*names)
        register(:view, *names)
      end

      def controllers(*names)
        register(:controller, *names)
      end
    end

    protected
      #
      # Subclasses should reimplement this to register or initialize models.
      #
      def setup_models
      end

      #
      # Subclasses should reimplement this to register or initialize main models.
      #
      def setup_main_models
      end

      #
      # Subclasses should reimplement this to register or initialize views.
      #
      def setup_views
      end

      #
      # Subclasses should reimplement this to register or initialize controllers.
      #
      def setup_controllers
      end

    private
      def after_register_model(model, name)
        model.register_observer(self, name)
        model.post_registration(self)
      end

      def after_register_main_model(model, name)
        after_register_model(model, name)
      end

      def after_register_view(view, name)
        view.register_controller(self)
        view.post_registration(self)
      end

      def after_register_controller(controller, name)
        controller.parent_controller = self
        controller.post_registration
      end

      def create_instance_arguments_for_controller
        [self]
      end

      def get_instance_for_main_model(name)
        main_controller.send(name) # should raise an error if main_controller doesn't have that main model.
      end

      def register_default_view
        default_view_name.camelize.constantize # Check if we can constantize view name, if this fails a NameError exception is thrown.
        register_view default_view_name
      rescue NameError
        # No default view for this controller, nothing to do.
      end

      def default_view_name
        "#{controller_name}_view"
      end

      def controller_name
        match = self.class.name.underscore.match(/([\w_]*)_controller/)
        match ? match[1] : self.class.name
      end

      def should_register_default_view?
        RuGUI.configuration.automatically_register_conventionally_named_views
      end

      # Navigates through the controllers hierarchy trying to find the main
      # controller (i.e., a class that extends RuGUI::BaseMainController).
      def find_main_controller
        if self.parent_controller.is_a?(RuGUI::BaseMainController)
          self.parent_controller
        elsif self.parent_controller == self
          return nil
        else
          self.parent_controller.main_controller
        end
      end
  end

  #
  # A base class for main controllers.
  #
  # Provides a method for running the application as well as a method to quit.
  #
  class BaseMainController < BaseController
    # Returns the framework_adapter for this class.
    def framework_adapter
      framework_adapter_for('BaseMainController')
    end

    #
    # Runs the application.
    #
    def run
      logger.info "Starting the application through #{self.class.name}."
      self.framework_adapter.run
    end

    #
    # Refreshes the GUI application, running just one event loop.
    #
    # This method is mostly useful when writing tests. It shouldn't be used
    # in normal applications.
    #
    def refresh
      self.framework_adapter.refresh
    end

    #
    # Exits from the application.
    #
    def quit
      logger.info "Exiting the application through #{self.class.name}."
      self.framework_adapter.quit
      logger.info "Application finished."
    end
  end
end
