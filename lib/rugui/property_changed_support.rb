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
      def when_property_changed(property, options = {}, &block)
        property_changed_block = RuGUI::PropertyChangedSupport::PropertyChangedBlock.new
        property_changed_block.property = property
        property_changed_block.options = options
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

      # Call the block configurated for the property changed if a block exists for the one.
      def call_property_changed_block_if_exists(observable, property, new_value, old_value)
        call_property_changed_block(observable, new_value, old_value) if block_exists?(observable, property, new_value, old_value)
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
          self.block.call(observable, new_value, old_value)
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
    end
  end
end
