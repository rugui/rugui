# Do not change this file!
#
# This was mainly copied (but modified a little bit) from the rails framework
# initializers, but made less picky about gem loading.

APPLICATION_ROOT = File.expand_path("#{File.dirname(__FILE__)}/..") unless defined?(APPLICATION_ROOT)

module RuGUI
  class << self
    def boot!
      unless booted?
        preinitialize
        pick_boot.run
      end
    end

    def booted?
      defined? RuGUI::Initializer
    end

    def pick_boot
      (vendor_rugui? ? VendorBoot : GemBoot).new
    end

    def vendor_rugui?
      File.exist?("#{APPLICATION_ROOT}/vendor/rugui")
    end

    def preinitialize
      load(preinitializer_path) if File.exist?(preinitializer_path)
    end

    def preinitializer_path
      "#{APPLICATION_ROOT}/config/preinitializer.rb"
    end
  end

  class Boot
    def run
      load_initializer
      RuGUI::Initializer.run(:set_load_path)
    end
  end

  class VendorBoot < Boot
    def load_initializer
      require "#{APPLICATION_ROOT}/vendor/rugui/lib/rugui/initializer"
    end
  end

  class GemBoot < Boot
    def load_initializer
      self.class.load_rubygems
      load_rugui
      require 'rugui/initializer'
    end

    def load_rugui
      require 'rugui'
    rescue Gem::LoadError
      $stderr.puts %(Missing the RuGUI gem. Please `gem install rugui`.)
      exit 1
    end

    class << self
      def rubygems_version
        Gem::RubyGemsVersion if defined? Gem::RubyGemsVersion
      end

      def load_rubygems
        require 'rubygems'
      rescue LoadError
        $stderr.puts %(RuGUI requires RubyGems. Please install RubyGems and try again: http://rubygems.rubyforge.org)
        exit 1
      end
    end
  end
end

# All that for this:
RuGUI.boot!
