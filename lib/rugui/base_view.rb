module RuGUI
  # A base class for views.
  #
  # To use this class create a subclass, and reimplement #setup_widgets, if you
  # want to create your interface by hand.
  # 
  # If you are using GTK framework adapter (the default) you may call
  # #builder_file and #use_glade, case you want to have your interface created
  # by a glade file.
  #
  # The view may have ViewHelpers, which works as 'models' for views, i.e., they
  # have observable properties that can be observed by the view. A default
  # helper, named as <code>{view_name}Helper</code> is registered if it exists.
  # For example, for a view named *MyView*, the default view helper should be
  # named *MyViewHelper*. This helper can be accessed as a <code>helper</code>
  # attribute. Other helpers may be registered if needed.
  #
  # Example (using GTK framework adapter):
  #   class MyGladeView < RuGUI::BaseView
  #     builder_file 'my_file.glade'
  #     root :top_window
  #     use_glade
  #   end
  #
  #   class MyHandView < RuGUI::BaseView
  #     def setup_widgets
  #       # do your hand-made code here...
  #     end
  #   end
  class BaseView < BaseObject
    include RuGUI::LogSupport
    include RuGUI::PropertyObserver

    attr_accessor :controllers
    attr_reader :unnamed_widgets
    
    class_inheritable_accessor :configured_builder_file
    class_inheritable_accessor :configured_builder_file_extension
    class_inheritable_accessor :configured_root

    def initialize
      @controllers = {}
      @helpers = {}
      @unnamed_widgets = []
      @widgets = {}

      register_default_helper
      setup_view_helpers
      build_from_builder_file
      setup_widgets
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks

    # Returns the framework_adapter for this class.
    def framework_adapter
      framework_adapter_for('BaseView')
    end

    # Reimplement this method to create widgets by hand.
    def setup_widgets
    end
    
    # Reimplement this method to setup view helpers.
    def setup_view_helpers
    end

    # Adds the given widget to a container widget.
    def add_widget_to_container(widget, container_widget_or_name)
      self.framework_adapter.add_widget_to_container(widget, from_widget_or_name(container_widget_or_name))
    end

    # Adds the given widget to a container widget.
    def remove_widget_from_container(widget, container_widget_or_name)
      self.framework_adapter.remove_widget_from_container(widget, from_widget_or_name(container_widget_or_name))
    end

    # Includes a view root widget inside the given container widget.
    def include_view(container_widget_name, view)
      raise RootWidgetNotSetForIncludedView, "You must set a root for views to be included." if view.root_widget.nil?
      add_widget_to_container(view.root_widget, container_widget_name)
    end

    # Removes a view root widget from the given container widget.
    def remove_view(container_widget_name, view)
      raise RootWidgetNotSetForIncludedView, "You must set a root for views to be removed." if view.root_widget.nil?
      remove_widget_from_container(view.root_widget, container_widget_name)
    end

    # Removes all children from the given container widget
    def remove_all_children(container_widget)
      self.framework_adapter.remove_all_children(container_widget)
    end

    # Registers a controller as receiver of signals from the view widgets.
    def register_controller(controller, name = nil)
      name ||= controller.class.to_s.underscore
      autoconnect_signals(controller)
      @controllers[name.to_sym] = controller
    end

    # Registers a view helper for the view.
    def register_helper(helper, name = nil)
      helper = create_instance_if_possible(helper) if helper.is_a?(String) or helper.is_a?(Symbol)
      unless helper.nil?()
        name ||= helper.class.to_s.underscore
        helper.register_observer(self, name)
        @helpers[name.to_sym] = helper
        create_attribute_reader(:helpers, name)
        helper.post_registration(self)
      end
    end

    # Called after the view is registered in a controller.
    def post_registration(controller)
    end

    # Returns the root widget if one is set.
    def root_widget
      send(root.to_sym) if not root.nil?
    end

    # Returns the builder file.
    def builder_file
      self.configured_builder_file
    end

    # Returns the builder file extension.
    def builder_file_extension
      self.configured_builder_file_extension
    end

    # Returns the name of the root widget for this view.
    def root
      self.configured_root.to_s unless self.configured_root.nil?
    end

    # Framework adapters should implement this if they support builder files.
    def build_from_builder_file
    end

    class << self
      # Sets the name of the root widget for this view.
      #
      # This is specially useful when more than one view uses the same glade
      # file, but each one uses a diferent widget tree inside that glade file.
      #
      # Other use for this is when building a reusable widget, composed of the
      # contents of a glade file. One could create a window, place a vertical
      # box, and then place elements inside this vertical box. Later, this glade
      # file is used to insert the contents of the vertical box inside another
      # vertical box in other glade file.
      def root(root_widget_name)
        self.configured_root = root_widget_name
      end
    end

    protected
      # Builds a widget of the given type, possibly adding it to a parent
      # widget, and display it.
      #
      # The *args are passed to the widget constructor.
      def build_widget(widget_type, widget_name = nil, parent = nil, *args)
        widget = widget_type.new(*args)
        self.framework_adapter.set_widget_name(widget, widget_name)
        add_widget(widget, widget_name)
        add_widget_to_container(widget, parent) unless parent.nil?
        widget.show
      end

      # Adds the widget to the view.
      #
      # If +widget_name+ is not given one is assumed the widget`s name will be
      # used instead. If the widget doesn't have a name it will be added as an
      # unnamed widget (accessible through #unnamed_widgets property.
      def add_widget(widget, widget_name = nil)
        widget_name ||= widget.name
        widget_name = widget_name.to_s

        unless widget_name.nil? || widget_name.empty?
          create_attribute_for_widget(widget_name)
          send("#{widget_name}=", widget)
          @widgets[widget_name] = widget
        else
          @unnamed_widgets << widget
        end
      end

      def from_widget_or_name(widget_or_name)
        if widget_or_name.is_a?(String) || widget_or_name.is_a?(Symbol)
          send(widget_or_name)
        else
          widget_or_name
        end
      end

      def autoconnect_signals(controller)
        self.framework_adapter.autoconnect_signals(self, controller)
      end

    private
      def get_builder_file
        filename = (not self.builder_file.nil?) ? self.builder_file : "#{self.class.to_s.underscore}.#{builder_file_extension}"

        # The builder file given may already contain a full path to a glade file.
        return filename if File.file?(filename)

        filename = "#{filename}.#{builder_file_extension}" unless File.extname(filename) == ".#{builder_file_extension}"

        paths = RuGUI.configuration.builder_files_paths.select do |path|
          File.file?(File.join(path, filename))
        end
        File.join(paths.first, filename) unless paths.empty?
      end

      # Attempts to register the default helper for the view
      def register_default_helper
        register_helper("#{self.class.name}Helper", :helper)
      end

      def create_attribute_for_widget(widget_name)
        self.instance_eval <<-instance_eval
          def #{widget_name}
            @#{widget_name}
          end

          def #{widget_name}=(widget)
            @#{widget_name} = widget
          end
        instance_eval
      end

      # Creates an attribute reader for the some entity.
      def create_attribute_reader(entity, name)
        self.class.class_eval <<-class_eval
          def #{name}
            @#{entity}[:#{name}]
          end
        class_eval
      end

      # Creates an instance of the given class.
      def create_instance_if_possible(klass_name, *args)
        klass_name.to_s.camelize.constantize.new(*args)
      rescue NameError
        # Couldn't create instance.
      end
  end

  # Exception thrown when the builder file for this view could not be found.
  class BuilderFileNotFoundError < Exception
  end

  # Exception thrown when attempting to include a view which don't have a root
  # set.
  class RootWidgetNotSetForIncludedView < Exception
  end
end
