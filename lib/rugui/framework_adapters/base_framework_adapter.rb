module RuGUI
  module FrameworkAdapters
    module BaseFrameworkAdapter
      class Base
        attr_accessor :adapted_object

        def initialize(adapted_object)
          self.adapted_object = adapted_object
        end
      end

      # Adapts the BaseController methods specific for the framework.
      class BaseController < Base
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
        end
      end

      # Adapts the BaseMainController methods specific for the framework.
      class BaseMainController < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseController
        # Runs the application, starting anything the framework needs.
        def run
        end

        # Refreshes the GUI application, running just one event loop.
        #
        # This method is mostly useful when writing tests. It shouldn't be used
        # in normal applications.
        def refresh
        end

        # Exits the application, freeing any resources used by the framework.
        def quit
        end
      end

      # Adapts the BaseModel methods specific for the framework
      class BaseModel < Base
      end

      # Adapts the BaseView methods specific for the framework
      class BaseView < Base
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
        end

        # Adds a widget to the given container widget.
        def add_widget_to_container(widget, container_widget)
        end

        # Removes a widget from the given container widget.
        def remove_widget_from_container(widget, container_widget)
        end

        # Removes all children from the given container widget.
        def remove_all_children(container_widget)
        end

        # Sets the widget name for the given widget if given.
        def set_widget_name(widget, widget_name)
        end

        # Autoconnects signals handlers for the view. If +other_target+ is given
        # it is used instead of the view itself.
        def autoconnect_signals(view, other_target = nil)
        end

        # Connects the signal from the widget to the given receiver block.
        # The block is executed in the context of the receiver.
        def connect_declared_signal_block(widget, signal, receiver, block)
        end

        # Connects the signal from the widget to the given receiver method.
        def connect_declared_signal(widget, signal, receiver, method)
        end

        # Builds widgets from the given filename, using the proper builder.
        def build_widgets_from(filename)
        end

        # Registers widgets as attributes of the view class.
        def register_widgets
        end

        class << self
          # Returns the builder file extension to be used for this view class.
          def builder_file_extension
          end
        end
      end

      # Adapts the BaseViewHelper methods specific for the framework
      class BaseViewHelper
      end
    end
  end
end
