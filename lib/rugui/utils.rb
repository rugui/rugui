require 'rugui/configuration'

module RuGUI
  module Utils
    module InspectDisabler
      # Disables the inspect method based on the configuration.
      def disable_inspect
        if RuGUI.configuration.disable_inspect
          self.class.class_eval <<-class_eval
            def inspect
            end
          class_eval
        end
      end
    end
  end
end
