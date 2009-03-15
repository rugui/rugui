require 'gtk2'
require 'libglade2'

module Gtk
  GTK_PENDING_BLOCKS = []
  GTK_PENDING_BLOCKS_LOCK = Monitor.new

  def Gtk.queue(&block)
    if Thread.current == Thread.main
      block.call
    else
      GTK_PENDING_BLOCKS_LOCK.synchronize do
        GTK_PENDING_BLOCKS << block
      end
    end
  end

  # Adds a timeout to execute pending blocks in a queue.
  def Gtk.queue_timeout(timeout)
    Gtk.timeout_add timeout do
      GTK_PENDING_BLOCKS_LOCK.synchronize do
        GTK_PENDING_BLOCKS.each do |block|
          block.call
        end
        GTK_PENDING_BLOCKS.clear
      end
      true
    end
  end

  def Gtk.load_style_paths
    styles_paths = RuGUI.configuration.styles_paths.select { |path| File.directory?(path) }
    styles_paths.each do |path|
      Dir.new(path).each do |entry|
        Gtk::RC.parse_string(get_style_file_contents(path, entry)) if is_style_file?(path, entry)
      end
    end
  end

  def Gtk.is_style_file?(path, filename)
    File.extname(filename) == '.rc' or /gtkrc/.match(filename) if File.file?(File.join(path, filename))
  end

  def Gtk.get_style_file_contents(path, filename)
    IO.read(File.join(path, filename)).sub('{ROOT_PATH}', RuGUI.configuration.root_path)
  end
end

Gtk.load_style_paths

module RuGUI
  module FrameworkAdapters
    module GTK
      class BaseController
        def queue(&block)
          Gtk.queue(&block)
        end
      end

      class BaseMainController < RuGUI::FrameworkAdapters::GTK::BaseController
        def run
          Gtk.queue_timeout(RuGUI.configuration.queue_timeout)
          Gtk.main
        end

        def quit
          Gtk.main_quit
        end
      end

      class BaseView
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
          Gtk.queue(&block)
        end

        # Adds a widget to the given container widget.
        def add_widget_to_container(widget, container_widget)
          container_widget.add(widget)
        end

        # Removes a widget from the given container widget.
        def remove_widget_from_container(widget, container_widget)
          container_widget.remove(widget)
        end

        # Removes all children from the given container widget.
        def remove_all_children(container_widget)
          container_widget.children.each do |child|
            container_widget.remove(child)
          end
        end

        # Sets the widget name for the given widget if given.
        def set_widget_name(widget, widget_name)
          widget.name = widget_name.to_s unless widget_name.nil?
        end

        # Autoconnects signals handlers for the view. If +other_target+ is given
        # it is used instead of the view itself.
        def autoconnect_signals(view, other_target = nil)
          if view.use_glade
            view.glade.signal_autoconnect_full do |source, target, signal_name, handler_name, signal_data, after|
              target ||= other_target
              view.glade.connect(source, target, signal_name, handler_name, signal_data) if target.respond_to?(handler_name)
            end
          end
        end
      end
    end
  end
end

module RuGUI
  class BaseView < BaseObject
    class_inheritable_accessor :configured_glade_usage

    attr_accessor :glade

    # Adds a signal handler for all widgets of the given type.
    def add_signal_handler_for_widget_type(widget_type, signal, &block)
      widgets = []
      widgets.concat(@widgets.values.select { |widget| widget.kind_of?(widget_type) }) unless @widgets.empty?
      widgets.concat(@unnamed_widgets.select { |widget| widget.kind_of?(widget_type) }) unless @unnamed_widgets.empty?

      widgets.each do |widget|
        widget.signal_connect(signal, &block)
      end
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

    # Returns true if glade is being used, false otherwise.
    def use_glade
      self.configured_glade_usage
    end

    def build_from_builder_file
      build_from_glade if use_glade
    end

    class << self
      # Sets the builder file to use when creating this view.
      def builder_file(file)
        self.configured_builder_file = file
      end
      
      # Call this method at class level if the view should be built from a glade
      # file.
      def use_glade
        RuGUI.configuration.builder_files_paths << "#{RuGUI.root}/app/resources/glade" unless RuGUI.configuration.builder_files_paths.include?("#{RuGUI.root}/app/resources/glade")
        self.configured_builder_file_extension = 'glade'
        self.configured_glade_usage = true
      end

      # This turns of the use of glade for this view class.
      def dont_use_glade
        self.configured_builder_file_extension = ''
        self.configured_glade_usage = false
      end
    end

    # By default we don't use glade.
    dont_use_glade

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

      # Registers widgets as attributes of the view class.
      def register_widgets
        @glade.widget_names.each do |widget_name|
          unless @glade[widget_name].nil?
            self.send("#{widget_name}=".to_sym, @glade[widget_name])
            @widgets[widget_name] = @glade[widget_name]
          end
        end
      end
  end
end