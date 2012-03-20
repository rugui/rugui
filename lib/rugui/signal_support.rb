module RuGUI
  module SignalSupport
    module ClassMethods
      # Declares a signal handler for the given signal of the widget. The
      # handler may be a method of this class or a block, which will be run with
      # the instance of this class as context.
      #
      # If the signal has arguments they are passed to the receiver method or
      # the block.
      def on(widget_name, signal_name, receiver_method_name = nil, &block)
        if receiver_method_name.nil? and not block_given?
          logger.warn "Either a block or a receiver_method_name must be given to on(#{widget_name}, #{signal_name}), ignoring call."
          return
        end

        signal_connection = RuGUI::SignalSupport::SignalConnection.new
        signal_connection.widget_name = widget_name
        signal_connection.signal_name = signal_name
        signal_connection.receiver_method_name = receiver_method_name
        signal_connection.receiver_block = block if block_given?
        signal_connection.receiver_class = self

        self.signal_connections << signal_connection
      end
    end

    # Autoconnects declared signal handlers for the widgets in the sender to
    # methods in this instance, or to blocks which have this instance as context.
    def autoconnect_declared_signals(sender)
      self.signal_connections.each do |signal_connection|
        if sender.respond_to?(signal_connection.widget_name)
          widget = sender.send(signal_connection.widget_name)

          if (not signal_connection.receiver_block.nil?) and self.is_a?(signal_connection.receiver_class)
            sender.framework_adapter.connect_declared_signal_block(widget, signal_connection.signal_name, self, signal_connection.receiver_block)
          elsif not signal_connection.receiver_method_name.nil? and self.respond_to?(signal_connection.receiver_method_name)
            sender.framework_adapter.connect_declared_signal(widget, signal_connection.signal_name, self, signal_connection.receiver_method_name)
          end
        end
      end
    end

    def self.included(base)
      base.class_attribute :signal_connections
      base.signal_connections = []
      base.extend(ClassMethods)
    end

    class SignalConnection
      attr_accessor :widget_name
      attr_accessor :signal_name
      attr_accessor :receiver_method_name
      attr_accessor :receiver_block
      attr_accessor :receiver_class
    end
  end
end
