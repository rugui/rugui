module RuGUI
  module Plugin
    class Loader
      attr_accessor :initializer
      attr_accessor :configurations
      cattr_accessor :located_plugins

      def initialize(initializer, configurations)
        self.initializer = initializer
        self.configurations = configurations
        @@located_plugins ||= []
      end

      def load_plugins
        plugins.each do |plugin|
          plugin.load unless plugin.loaded?
          register_as_loaded(plugin)
        end
      end

      def plugins
        @plugins ||= locate_plugins
      end

      protected
        # Locate all plugins in APPLICATION_ROOT/vendor/plugins
        def locate_plugins
          Dir.glob(File.join(APPLICATION_ROOT, "vendor", "plugins", "*")).each do |dir|
            @@located_plugins << Location.new(dir)
          end
          @@located_plugins
        end

        # Register plugins as loaded.
        def register_as_loaded(plugin)
          plugin.loaded = true
        end
    end

    # This class is a representation of RuGUI plugins.
    class Location
      attr_accessor :dir
      attr_accessor :loaded

      include RuGUI::LogSupport

      def initialize(dir)
        self.dir = dir
      end

      # Load plugins.
      def load
        $LOAD_PATH.unshift(File.join(self.dir, "lib")) if File.directory?(self.dir)
        $LOAD_PATH.uniq!

        init_file = File.expand_path(File.join(self.dir, "init.rb"))
        if File.exist?(init_file)
          require init_file
        else
          logger.warn "The init.rb of plugin (#{self.dir}) was not found."
        end
      end

      def loaded?
        self.loaded ||= false
      end
    end
  end
end
