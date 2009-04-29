module RuGUI
  class BaseModel < BaseObject
    include RuGUI::ObservablePropertySupport
    include RuGUI::LogSupport

    def initialize(observable_properties_values = {})
      initialize_observable_property_support(observable_properties_values)
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks

    # Returns the framework_adapter for this class.
    def framework_adapter
      framework_adapter_for('BaseModel')
    end

    # Called after the model is registered in a controller.
    def post_registration(controller)
    end
  end
end
