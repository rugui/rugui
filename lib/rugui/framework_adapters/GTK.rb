require 'gtk2'
require 'libglade2'

unless Object.respond_to?(:instance_exec) # Ruby 1.9 does already has Object#instance_exec
  # See the discussion here: http://eigenclass.org/hiki.rb?instance_exec
  class Object
    module InstanceExecHelper; end
    include InstanceExecHelper
    def instance_exec(*args, &block)
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(mname="__instance_exec#{n}")
        InstanceExecHelper.module_eval{ define_method(mname, &block) }
      ensure
        Thread.critical = old_critical
      end
      begin
        ret = send(mname, *args)
      ensure
        InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
      end
      ret
    end
  end
end

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
    IO.read(File.join(path, filename)).gsub('{ROOT_PATH}', RuGUI.configuration.root_path.to_s)
  end
end

Gtk.load_style_paths

module RuGUI
  module FrameworkAdapters
    module GTK
      class BaseController < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseController
        def queue(&block)
          Gtk.queue(&block)
        end
      end

      class BaseMainController < RuGUI::FrameworkAdapters::GTK::BaseController
        def run
          Gtk.queue_timeout(RuGUI.configuration.queue_timeout)
          Gtk.main
        end

        def refresh
          Gtk.main_iteration_do(false) while Gtk.events_pending?
        end

        def quit
          Gtk.main_quit
        end
      end

      class BaseView < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseView
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
        def autoconnect_signals(other_target = nil)
          if self.adapted_object.use_builder?
            self.adapted_object.glade.signal_autoconnect_full do |source, target, signal_name, handler_name, signal_data, after|
              target ||= other_target
              self.adapted_object.glade.connect(source, target, signal_name, handler_name, signal_data) if target.respond_to?(handler_name)
            end
          end
        end

        # Connects the signal from the widget to the given receiver block.
        # The block is executed in the context of the receiver.
        def connect_declared_signal_block(widget, signal, receiver, block)
          widget.signal_connect(signal) do |*args|
            receiver.instance_exec(*args, &block)
          end
        end

        # Connects the signal from the widget to the given receiver method.
        def connect_declared_signal(widget, signal, receiver, method)
          widget.signal_connect(signal) do |*args|
            receiver.send(method, *args)
          end
        end

        # Builds widgets from the given filename, using the proper builder.
        def build_widgets_from(filename)
          self.adapted_object.glade = GladeXML.new(filename, self.adapted_object.root, nil, nil, GladeXML::FILE)

          self.adapted_object.glade.widget_names.each do |widget_name|
            self.adapted_object.send(:create_attribute_for_widget, widget_name) unless self.adapted_object.glade[widget_name].nil?
          end
          self.adapted_object.root_widget.show if self.adapted_object.display_root? and not self.adapted_object.root_widget.nil?
        end

        # Registers widgets as attributes of the view class.
        def register_widgets
          self.adapted_object.glade.widget_names.each do |widget_name|
            unless self.adapted_object.glade[widget_name].nil?
              self.adapted_object.send("#{widget_name}=".to_sym, self.adapted_object.glade[widget_name])
              self.adapted_object.widgets[widget_name] = self.adapted_object.glade[widget_name]
            end
          end
        end

        class << self
          # Returns the builder file extension to be used for this view class.
          def builder_file_extension
            'glade'
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
        widget.signal_connect(signal, &block) unless widget.destroyed?
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

    class << self
      # Call this method at class level if the view should be built from a glade
      # file.
      def use_glade
        self.logger.warn('DEPRECATED - Call use_builder class method instead in your view.')
        use_builder
      end
    end
  end
end