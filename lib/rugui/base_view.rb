require 'rubygems'
require 'active_support'
require 'gtk2'
require 'libglade2'

module RuGUI
  # A base class for views.
  # 
  # To use this class create a subclass, and reimplement #setup_widgets, if you
  # want to create your interface by hand, or call #builder_file and #use_glade,
  # if you want to have your interface created in a glade file.
  # 
  # The view may have ViewHelpers, which works as 'models' for views, i.e., they
  # have observable properties that can be observed by the view. A default
  # helper, named as <code>{view_name}Helper</code> is registered if it exists.
  # For example, for a view named *MyView*, the default view helper should be
  # named *MyViewHelper*. This helper can be accessed as a <code>helper</code>
  # attribute. Other helpers may be registered if needed.
  # 
  # Example:
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
  class BaseView
    include RuGUI::Utils::InspectDisabler
    include RuGUI::LogSupport
    include RuGUI::PropertyObserver
    
    attr_accessor :controllers
    attr_reader :unnamed_widgets
    
    def initialize
      disable_inspect
      initialize_logger self.class.to_s
      
      @controllers = {}
      @helpers = {}
      @unnamed_widgets = []
      @widgets = {}
      
      register_default_helper
      build_from_glade if use_glade
      setup_widgets
    end
    
    # Reimplement this method to create widgets by hand.
    def setup_widgets
    end
    
    # Includes a view root widget inside the given container widget.
    def include_view(container_widget, view)
      raise RootWidgetNotSetForIncludedView, "You must set a root for included views." if view.root_widget.nil?
      send(container_widget.to_s).add(view.root_widget)
    end
    
    # Registers a controller as receiver of signals from the view widgets.
    def register_controller(controller, name = nil)
      name ||= controller.class.to_s.underscore
      autoconnect_signals(controller) if use_glade
      @controllers[name.to_sym] = controller
    end
    
    # Registers a view helper for the view.
    def register_helper(helper, name = nil)
      helper = create_instance_if_possible(helper) if helper.is_a?(String) or helper.is_a?(Symbol)
      unless helper.nil?()
        name ||= helper.class.to_s.underscore
        helper.register_observer(self)
        @helpers[name.to_sym] = helper
        create_attribute_reader(:helpers, name)
        helper.post_registration(self)
      end
    end
    
    # Called after the view is registered in a controller.
    def post_registration(controller)
    end

    # Adds a signal handler for all widgets of the given type.
    def add_signal_handler_for_widget_type(widget_type, signal, &block)
      widgets = []
      widgets.concat(@widgets.values.select { |widget| widget.kind_of?(widget_type) }) unless @widgets.empty?
      widgets.concat(@unnamed_widgets.select { |widget| widget.kind_of?(widget_type) }) unless @unnamed_widgets.empty?
      
      widgets.each do |widget|
        widget.signal_connect(signal, &block)
      end
    end
    
    # Returns the root widget if one is set.
    def root_widget
      send(root.to_sym) if self.respond_to?(:root) && !root.nil?
    end
    
    # Changes the widget style to use the given widget style.
    #
    # This widget style should be declared in a gtkrc file, by specifying a
    # style using a widget path, such as:
    #
    #   widget "main_window" style "main_window_style"
    #   widget "main_window_other" style "main_window_other_style"
    #
    # In this example, if you called this method like this:
    #
    #   change_widget_style(:main_window, 'main_window_other')
    #   change_widget_style(self.main_window, 'main_window_other')     # or, passing the widget instance directly
    #
    # The widget style would be set to "main_window_other_style".
    #
    # NOTE: Unfortunately, gtk doesn't offer an API to get declared styles, so
    # you must set a style to a widget. Since the widget name set in the style
    # definition doesn't need to point to an existing widget we can use this
    # to simplify the widget styling here.
    def change_widget_style(widget_or_name, widget_path_style)
      if widget_or_name.is_a?(Gtk::Widget)
        widget = widget_or_name
      else
        widget = @glade[widget_or_name.to_s]
      end
      style = Gtk::RC.get_style_by_paths(Gtk::Settings.default, widget_path_style.to_s, nil, nil)
      widget.style = style
    end
    
    protected
      # Sets the builder file to use when creating this view.
      def self.builder_file(file)
        create_fake_class_read_only_attribute(:builder_file, file)
      end
      
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
      def self.root(root_widget_name)
        create_fake_class_read_only_attribute(:root, root_widget_name)
      end
      
      # Returns the name of the root widget for this view.
      def root
      end

      # Call this method at class level if the view should be built from a glade
      # file.
      def self.use_glade
        create_fake_class_read_only_attribute(:use_glade, true)
      end
      
      # This turns of the use of glade for this view class.
      def self.dont_use_glade
        create_fake_class_read_only_attribute(:use_glade, false)
      end
      
      # Builds a widget of the given type, possibly adding it to a parent
      # widget, and display it.
      # 
      # The *args are passed to the widget constructor.
      def build_widget(widget_type, widget_name = nil, parent = nil, *args)
        widget = widget_type.new(*args)
        widget.name = widget_name.to_s unless widget_name.nil?
        add_widget(widget, widget_name)
        add_to_container(widget, parent) unless parent.nil?
        widget.show
      end
      
      # Adds the given widget to a container widget.
      def add_to_container(widget, parent)
        if parent.is_a?(String) || parent.is_a?(Symbol)
          parent_widget = send(parent)
        else
          parent_widget = parent
        end

        parent_widget.add(widget)
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
    
    private
      # Builds widgets from the specified glade file.
      def build_from_glade
        file = get_builder_file
        
        if file.nil?
          raise BuilderFileNotFoundError,
            "Could not find builder file for view #{self.class}. Glade file paths: #{RuGUI.configuration.glade_files_paths.join(', ')}."
        end
        
        @glade = GladeXML.new(file, root, nil, nil, GladeXML::FILE)

        @glade.widget_names.each do |widget_name|
          create_attribute_for_widget(widget_name) unless @glade[widget_name].nil?
        end
        
        register_widgets
        autoconnect_signals(self)
      end
      
      def get_builder_file
        filename = respond_to?(:builder_file) ? builder_file : "#{self.class.to_s.underscore}.glade"
        
        # The builder file given may already contain a full path to a glade file.
        return filename if File.file?(filename)
        
        filename = "#{filename}.glade" unless File.extname(filename) == ".glade"
        
        paths = RuGUI.configuration.glade_files_paths.select do |path|
          File.file?(File.join(path, filename))
        end
        File.join(paths.first, filename) unless paths.empty?
      end
      
      # Registers widgets as attributes of the view class.
      def register_widgets
        @glade.widget_names.each do |widget_name|
          unless @glade[widget_name].nil?
            self.send("#{widget_name}=".to_sym, @glade[widget_name])
            @widgets[widget_name] = @glade[widget_name]
          end
        end
      end
      
      # Attempts to register the default helper for the view
      def register_default_helper
        register_helper("#{self.class.name}Helper", :helper)
      end
      
      # Auto connects the signals from the glade file with the signal handlers
      # present in the given target.
      def autoconnect_signals(other_target = nil)
        @glade.signal_autoconnect_full do |source, target, signal_name, handler_name, signal_data, after|
          target ||= other_target
          @glade.connect(source, target, signal_name, handler_name, signal_data) if target.respond_to?(handler_name)
        end
      end
      
      def self.create_fake_class_read_only_attribute(attribute_getter, attribute_value)
        unless attribute_value.is_a?(String) || attribute_value.is_a?(Symbol)
          attribute_value = attribute_value.to_s
        else
          attribute_value = "'#{attribute_value}'"
        end
        
        self.class_eval <<-class_eval
          def #{attribute_getter}
            #{attribute_value}
          end
        class_eval
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
      
      # By default we don't use glade.
      dont_use_glade
  end
  
  # Exception thrown when the builder file for this view could not be found.
  class BuilderFileNotFoundError < Exception
  end
  
  # Exception thrown when attempting to include a view which don't have a root
  # set.
  class RootWidgetNotSetForIncludedView < Exception
  end
end