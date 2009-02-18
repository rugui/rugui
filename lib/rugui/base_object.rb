module RuGUI
  # A base object for all RuGUI classes.
  #
  # It mainly defines customized inspect which will display only some of the
  # instance variables, avoiding excessive overhead when generating tracebacks.
  class BaseObject
    # Returns a string containing a human-readable representation of obj.
    #
    # It will display each instance variable value unless it is also a
    # RuGUI::BaseObject.
    def inspect
      instance_variables_values = instance_variables.collect do |instance_variable_name|
        instance_variable_value = instance_variable_get(instance_variable_name)
        inspected_instance_variable_value = nil
        if instance_variable_value.is_a?(RuGUI::BaseObject)
          inspected_instance_variable_value = inspect_base_object(instance_variable_value)
        elsif instance_variable_value.is_a?(Array)
          inspected_instance_variable_value = inspect_array(instance_variable_value)
        elsif instance_variable_value.is_a?(Hash)
          inspected_instance_variable_value = inspect_hash(instance_variable_value)
        else
          inspected_instance_variable_value = instance_variable_value.inspect
        end

        "#{instance_variable_name}=#{inspected_instance_variable_value}"
      end

      "#<#{self.class.name} #{instance_variables_values.join(" ")}>"
    end

    protected
      def inspect_base_object(base_object_value)
        "#<#{base_object_value.class.inspect}>"
      end

      def inspect_array(array_value)
        array_values = array_value.collect do |item|
          if item.is_a?(RuGUI::BaseObject)
            inspect_base_object(item)
          elsif item.is_a?(Array)
            inspect_array(item)
          elsif item.is_a?(Hash)
            inspect_hash(item)
          else
            item.inspect
          end
        end

        "[#{array_values.join(', ')}]"
      end

      def inspect_hash(hash_value)
        hash_values = hash_value.collect do |key, value|
          inspected_value = nil
          if value.is_a?(RuGUI::BaseObject)
            inspected_value = inspect_base_object(value)
          elsif value.is_a?(Array)
            inspected_value = inspect_array(value)
          elsif value.is_a?(Hash)
            inspected_value = inspect_hash(value)
          else
            inspected_value = value.inspect
          end
          "#{key.inspect}=>#{inspected_value}"
        end

        "{#{hash_values.join(', ')}}"
      end
  end
end