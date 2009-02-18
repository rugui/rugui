module RuGUI
  class BaseModel < BaseObject
    include RuGUI::ObservablePropertySupport
    include RuGUI::LogSupport
    
    def initialize(observable_properties_values = {})
      initialize_observable_property_support(observable_properties_values)
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks
    
    # Called after the model is registered in a controller.
    def post_registration(controller)
    end
  end
end
