module RuGUI
  # A base class for view helpers.
  class BaseViewHelper
    include RuGUI::ObservablePropertySupport
    include RuGUI::Utils::InspectDisabler
    include RuGUI::LogSupport
    
    def initialize(observable_properties_values = {})
      disable_inspect
      initialize_observable_property_support(observable_properties_values)
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks

    # Called after the view helper is registered in a view.
    def post_registration(view)
    end
  end
end
