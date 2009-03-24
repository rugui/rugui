require 'Qt4'
require 'qtuitools'

module Qt
  def Qt.create_application
    @@application = Qt::Application.new(ARGV)
  end

  def Qt.application
    @@application
  end
end

Qt.create_application

module RuGUI
  module FrameworkAdapters
    module Qt4
      class BaseController < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseController
        def queue(&block)
          block.call
        end
      end

      class BaseMainController < RuGUI::FrameworkAdapters::Qt4::BaseController
        def run
          Qt.application.exec
        end

        def quit
          Qt.application.exit
        end
      end

      class BaseView < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseView
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
          block.call
        end

        # Adds a widget to the given container widget.
        def add_widget_to_container(widget, container_widget)
          widget.parent = container_widget
        end

        # Removes a widget from the given container widget.
        def remove_widget_from_container(widget, container_widget)
          widget.dispose
        end

        # Removes all children from the given container widget.
        def remove_all_children(container_widget)
          container_widget.children.each do |child|
            child.dispose
          end
        end

        # Sets the widget name for the given widget if given.
        def set_widget_name(widget, widget_name)
          widget.object_name = widget_name
        end

        # Autoconnects signals handlers for the view. If +other_target+ is given
        # it is used instead of the view itself.
        def autoconnect_signals(view, other_target = nil)
          # Qt4 doesn't provides a method for autoconnecting signals.
        end

        # Connects the signal from the widget to the given receiver block.
        # The block is executed in the context of the receiver.
        def connect_declared_signal_block(widget, signal, receiver, block)
          widget.connect(SIGNAL(signal)) do |*args|
            receiver.instance_exec(*args, &block)
          end
        end

        # Connects the signal from the widget to the given receiver method.
        def connect_declared_signal(widget, signal, receiver, method)
          widget.connect(SIGNAL(signal)) do |*args|
            receiver.send(method, *args)
          end
        end

        # Builds widgets from the given filename, using the proper builder.
        def build_widgets_from(filename)
          ui_file_root_widget = load_ui_file(filename)
          @view_root_widget = root_widget_from(ui_file_root_widget)
          create_attributes_for_widget_and_children(@view_root_widget)
          @view_root_widget.show
        end

        # Registers widgets as attributes of the view class.
        def register_widgets
          register_widget_and_children(@view_root_widget)
        end

        class << self
          # Returns the builder file extension to be used for this view class.
          def builder_file_extension
            'ui'
          end
        end

        private
          def load_ui_file(filename)
            file = Qt::File.new(filename)
            file.open(Qt::File::ReadOnly)
            loader = Qt::UiLoader.new
            loader.load(file, nil)
          end

          def root_widget_from(ui_file_root_widget)
            self.adapted_object.root.nil? ? ui_file_root_widget : ui_file_root_widget.find_child(self.adapted_object.root)
          end

          def create_attributes_for_widget_and_children(widget)
            self.adapted_object.send(:create_attribute_for_widget, widget.object_name)
            widget.children.each do |child|
              create_attributes_for_widget_and_children(child) unless child.object_name.blank?
            end
          end

          # Registers widgets as attributes of the view class.
          def register_widget_and_children(widget)
            register_widget(widget)
            widget.children.each do |child|
              register_widget_and_children(child)
            end
          end

          def register_widget(widget)
            unless widget.object_name.nil?
              self.adapted_object.send("#{widget.object_name}=", widget)
              self.adapted_object.widgets[widget.object_name] = widget
            else
              self.adapted_object.unnamed_widgets << widget
            end
          end
      end
    end
  end
end

module RuGUI
  class BaseView < BaseObject
    # An utility method to connect Qt signals between two Qt::Object.
    #
    # If receiver is given, it will be used instead of the view itself.
    def connect(sender, signal, slot, receiver = nil)
      sender = from_widget_or_name(sender)
      receiver = receiver.nil? ? self : from_widget_or_name(receiver)
      if receiver.is_a?(Qt::Object)
        Qt::Object.connect(sender, SIGNAL(signal), receiver, SLOT(slot))
      elsif receiver.is_a?(RuGUI::BaseObject)
        sender.connect(SIGNAL(signal)) { |*args| receiver.send(slot, *args) if receiver.respond_to?(slot) }
      end
    end
  end
end