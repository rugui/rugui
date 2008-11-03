require 'rugui/utils'

module RuGUI
  class BaseModel
    include RuGUI::ObservablePropertySupport
    include RuGUI::Utils::InspectDisabler
    include RuGUI::LogSupport
    
    def initialize
      disable_inspect
      initialize_logger self.class.to_s
      initialize_observable_property_support
    end
    
    #
    # Called after the model is registered in a controller.
    #
    def post_registration(controller)
    end
  end
end
