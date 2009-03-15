module RuGUI
  # A base class for view helpers.
  class BaseViewHelper < BaseObject
    include RuGUI::ObservablePropertySupport
    include RuGUI::LogSupport
    
    def initialize(observable_properties_values = {})
      initialize_observable_property_support(observable_properties_values)
    end

    # This is included here so that the initialize method is properly updated.
    include RuGUI::InitializeHooks

    # Returns the framework_adapter for this class.
    def framework_adapter
      framework_adapter_for('BaseViewHelper')
    end

    # Called after the view helper is registered in a view.
    def post_registration(view)
    end
  end
end
