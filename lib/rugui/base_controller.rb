module RuGUI
  #
  # Base class for all controllers.
  #
  class BaseController < BaseObject
    include RuGUI::PropertyObserver
    include RuGUI::LogSupport
    include RuGUI::SignalSupport

    attr_accessor :models
    attr_accessor :views
    attr_accessor :controllers
    attr_accessor :parent_controller

    def initialize(parent_controller = nil)
      @models = {}
      @views = {}
      @controllers = {}

      if parent_controller.nil?
        @parent_controller = self
      else
        @parent_controller = parent_controller
      end

      setup_models

      register_default_view if should_register_default_view?
      setup_views

      setup_controllers
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
      model = register(:model, model, name)
      unless model.nil?
        model.register_observer(self, name)
        model.post_registration(self)
      end
    end

    #
    # Registers a view for this controller.
    #
    # If the given view is a string or symbol, it will be camelized and a new
    # instance of the view class will be created.
    #
    def register_view(view, name = nil)
      view = register(:view, view, name)
      unless view.nil?
        view.register_controller(self, name)
        view.post_registration(self)
      end
    end

    #
    # Registers a child controller for this controller.
    #
    # If the given controller is a string or symbol, it will be camelized and
    # a new instance of the controller class will be created.
    #
    def register_controller(controller, name = nil)
      controller = register(:controller, controller, name)
      unless controller.nil?
        controller.parent_controller = self
        controller.post_registration
      end
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

    protected
      #
      # Subclasses should reimplement this to register models.
      #
      def setup_models
      end

      #
      # Subclasses should reimplement this to register views.
      #
      def setup_views
      end

      #
      # Subclasses should reimplement this to register controllers.
      #
      def setup_controllers
      end

    private
      def register(type, object, name)
        if object.is_a?(String) or object.is_a?(Symbol)
          name ||= object.to_s.underscore
          return if respond_to?(name) and not send(name).nil? # don't register it again
        else
          name ||= object.class.to_s.underscore
          return if respond_to?(name) and not send(name).nil? # don't register it again
        end

        object = create_instance(object) if object.is_a?(String) or object.is_a?(Symbol)
        name ||= object.class.to_s.underscore
        send("#{type}s")[name.to_sym] = object
        create_attribute_reader(type, name)
        object
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

      def create_instance(klass_name, *args)
        klass_name.to_s.camelize.constantize.new(*args)
      end

      # Creates an attribute reader for the some entity.
      def create_attribute_reader(type, name)
        self.class.class_eval <<-class_eval
          def #{name}
            @#{type}s[:#{name}]
          end
        class_eval
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
