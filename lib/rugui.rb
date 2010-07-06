require 'rubygems'
require 'active_support'
require 'active_support/dependencies'
require 'active_support/core_ext'

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
        Pathname.new(File.expand_path(APPLICATION_ROOT))
      else
        nil
      end
    end
  end
end

require 'rugui/configuration'
require 'rugui/log_support'
require 'rugui/plugin/loader'
require 'rugui/framework_adapters/framework_adapter_support'
require 'rugui/base_object'
require 'rugui/property_changed_support'
require 'rugui/observable_property_support'
require 'rugui/property_observer'
require 'rugui/initialize_hooks'
require 'rugui/signal_support'
require 'rugui/entity_registration_support'
require 'rugui/base_controller'
require 'rugui/base_model'
require 'rugui/base_view_helper'
require 'rugui/base_view'
