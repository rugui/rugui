module RuGUI
  # A base class for view helpers.
  class BaseViewHelper
    include RuGUI::ObservablePropertySupport
    include RuGUI::Utils::InspectDisabler
    include RuGUI::LogSupport
    
    def initialize
      disable_inspect
      initialize_logger self.class.to_s
      initialize_observable_property_support
    end
    
    # Called after the view helper is registered in a view.
    def post_registration(view)
    end
  end
end