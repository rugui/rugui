require 'rubygems'
require 'active_support'
require 'gtk2'

module RuGUI
  #
  # Base class for all controllers.
  #
  class BaseController
    include RuGUI::PropertyObserver
    include RuGUI::Utils::InspectDisabler
    include RuGUI::LogSupport

    attr_accessor :models
    attr_accessor :views
    attr_accessor :controllers
    attr_accessor :parent_controller

    def initialize(parent_controller = nil)
      disable_inspect
      
      @models = {}
      @views = {}
      @controllers = {}

      if parent_controller.nil?
        @parent_controller = self
      else
        @parent_controller = parent_controller
      end

      setup_models
      setup_views
      setup_controllers
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks

    #
    # Registers a model for this controller.
    #
    # If the given model is a string or symbol, it will be camelized and
    # a new instance of the model class will be created.
    #
    def register_model(model, name = nil)
      model = create_instance(model) if model.is_a?(String) or model.is_a?(Symbol)
      name ||= model.class.to_s.underscore
      model.register_observer(self, name)
      @models[name.to_sym] = model
      create_model_attribute_reader(name)

      model.post_registration(self)
    end

    #
    # Registers a view for this controller.
    #
    # If the given view is a string or symbol, it will be camelized and a new
    # instance of the view class will be created.
    #
    def register_view(view, name = nil)
      view = create_instance(view) if view.is_a?(String) or view.is_a?(Symbol)
      name ||= view.class.to_s.underscore
      view.register_controller(self)
      @views[name.to_sym] = view
      create_view_attribute_reader(name)

      view.post_registration(self)
    end

    #
    # Registers a child controller for this controller.
    #
    # If the given controller is a string or symbol, it will be camelized and
    # a new instance of the controller class will be created.
    #
    def register_controller(controller, name = nil)
      controller = create_instance(controller, self) if controller.is_a?(String) or controller.is_a?(Symbol)
      name ||= controller.class.to_s.underscore
      controller.parent_controller = self
      @controllers[name.to_sym] = controller
      create_controller_attribute_reader(name)

      controller.post_registration
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
      def create_instance(klass_name, *args)
        klass_name.to_s.camelize.constantize.new(*args)
      end

      # Creates an attribute reader for the model.
      def create_model_attribute_reader(name)
        create_attribute_reader(:models, name)
      end

      # Creates an attribute reader for the view.
      def create_view_attribute_reader(name)
        create_attribute_reader(:views, name)
      end

      # Creates an attribute reader for the controller.
      def create_controller_attribute_reader(name)
        create_attribute_reader(:controllers, name)
      end

      # Creates an attribute reader for the some entity.
      def create_attribute_reader(entity, name)
        self.class.class_eval <<-class_eval
          def #{name}
            @#{entity}[:#{name}]
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
    #
    # Runs the application.
    #
    def run
      logger.info "Starting the application through #{self.class.name}."
      Gtk.main_with_queue
    end

    #
    # Exits from the application.
    #
    def quit
      logger.info "Exiting the application through #{self.class.name}."
      Gtk.main_quit
      logger.info "Application finished."
    end
  end
end
