require 'rugui/utils'

module RuGUI
  class BaseModel
    include RuGUI::ObservablePropertySupport
    include RuGUI::Utils::InspectDisabler
    include RuGUI::LogSupport
    
    def initialize(observable_properties_values = {})
      disable_inspect
      initialize_observable_property_support(observable_properties_values)
    end
    
    #
    # Called after the model is registered in a controller.
    #
    def post_registration(controller)
    end
  end
end
