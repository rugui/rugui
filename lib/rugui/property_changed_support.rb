module RuGUI
  module PropertyChangedSupport
    module ClassMethods
      # Invoked when a property was changed.
      #
      # Example:
      # <tt>
      # when_property_changed :name do |observable, new_value, old_value|
      #   puts "Hey! The property 'name' of the #{observable.class.name} was changed from #{old_value} to #{new_value}."
      # end
      # </tt>
      #
      # Or you can inform the observable:
      # <tt>
      # when_property_changed :name, :observable => :rabbit do |observable, new_value, old_value|
      #   puts "Hey! The property 'name' of the 'rabbit' was changed from #{old_value} to #{new_value}."
      # end
      # </tt>
      #
      # If you can inform a method to be called:
      # <tt>
      # when_property_changed :name, :puts_anything
      #
      # def puts_anything(observable, new_value, old_value)
      #   puts "Hey! The property 'name' of the #{observable.class.name} was changed from #{old_value} to #{new_value}."
      # end
      # </tt>
      #
      # Or you can inform the observable and a method to be called.
      # <tt>
      # when_property_changed :name, :observable => :rabbit, :call => :puts_anything
      #
      # def puts_anything(observable, new_value, old_value)
      #   puts "Hey! The property 'name' of the 'rabbit' was changed from #{old_value} to #{new_value}."
      # end
      # </tt>
      # </tt>
      #
      def when_property_changed(property, method_or_options = {}, &block)
        property_changed_block = RuGUI::PropertyChangedSupport::PropertyChangedBlock.new
        property_changed_block.property = property
        property_changed_block.set_options(method_or_options)
        property_changed_block.block = block if block_given?
        self.property_changed_blocks << property_changed_block
      end
    end

    def self.included(base)
      base.class_inheritable_accessor :property_changed_blocks
      base.property_changed_blocks = []
      base.extend(ClassMethods)
    end

    class PropertyChangedBlock
      attr_accessor :property
      attr_accessor :options
      attr_accessor :block
      attr_accessor :observer

      # Call the block configurated for the property changed if a block exists for the one.
      def call_property_changed_block_if_exists(observer, observable, property, new_value, old_value)
        self.observer = observer
        call_property_changed_block(observable, new_value, old_value) if block_exists?(observable, property, new_value, old_value)
      end

      # Set the options given the args.
      def set_options(method_or_options)
        case method_or_options
        when String, Symbol
          self.options = { :call => prepared(method_or_options) }
        when Hash
          self.options = method_or_options
        end
      end

      protected
        # Check if a block exists for the property changed
        def block_exists?(observable, property, new_value, old_value)
          if self.options.has_key?(:observable)
            return same_observable_and_property?(observable, property)
          else
            return same_property?(property)
          end
        end

        # Call the block configurated for the property changed.
        def call_property_changed_block(observable, new_value, old_value)
          return if not self.options.has_key?(:call) and self.block.blank?
          if self.options.has_key?(:call)
            method = self.options[:call]
            self.observer.send(method, observable, new_value, old_value) if self.observer.respond_to?(method)
          else
            self.block.call(observable, new_value, old_value) unless self.block.blank?
          end
        end

      private
        def same_property?(property)
          prepared(self.property) == prepared(property)
        end

        def same_observable?(observable)
          prepared(self.options[:observable]) == prepared(observable.class.name)
        end

        def same_observable_and_property?(observable, property)
          same_observable?(observable) and same_property?(property)
        end

        def prepared(param)
          param.to_s.downcase.underscore
        end

        def logger
          @logger ||= RuGUILogger.logger
        end
    end
  end
end
