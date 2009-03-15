require 'rugui/framework_adapters/base_framework_adapter'

module RuGUI
  module FrameworkAdapters
    module FrameworkAdapterSupport
      def framework_adapter_for(class_name)
        @framework_adapter ||= {}
        load_framework_adapter(class_name) unless @framework_adapter[class_name]
        @framework_adapter[class_name]
      end

      def load_framework_adapter(class_name)
        @framework_adapter[class_name] = class_adapter_for(class_name).new
      end

      def adapter_module_name(framework_adapter = RuGUI.configuration.framework_adapter)
        "RuGUI::FrameworkAdapters::#{framework_adapter.camelize}"
      end

      def class_adapter_for(class_name)
        "#{adapter_module_name}::#{class_name}".constantize
      rescue
        # Fallback to the base_framework_adapter.
        "#{adapter_module_name('base_framework_adapter')}::#{class_name}".constantize
      end
    end
  end
end
