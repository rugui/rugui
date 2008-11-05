module RuGUI
  class << self
    # The Configuration instance used to configure the RuGUI environment
    def configuration
      @@configuration
    end

    def configuration=(configuration)
      @@configuration = configuration
    end

    def root
      if defined?(APPLICATION_ROOT)
        APPLICATION_ROOT
      else
        nil
      end
    end
  end
end

require 'rugui/configuration'
require 'rugui/utils'
require 'rugui/log_support'
require 'rugui/observable_property_support'
require 'rugui/property_observer'
require 'rugui/base_controller'
require 'rugui/base_model'
require 'rugui/base_view_helper'
require 'rugui/base_view'

