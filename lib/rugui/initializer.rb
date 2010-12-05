require 'rugui'
require 'rugui/gem_dependency'

module RuGUI
  class Initializer
    include RuGUI::LogSupport

    # The configuration for this application.
    attr_reader :configuration

    # Whether or not all the gem dependencies have been met
    attr_reader :gems_dependencies_loaded

    @@processed = false

    # Runs the initializer.
    #
    # It runs the process procedure by default, by this can be changed by
    # specifying a command when calling this method. A block can be given
    # in order to change the application configuration.
    #
    def self.run(command = :process, configuration = Configuration.new)
      yield configuration if block_given?
      initializer = new configuration
      RuGUI.configuration = configuration
      initializer.send(command)
      @@processed = (command == :process) ? true : false
      initializer
    end

    # Create a new Initializer instance that references the given Configuration
    # instance.
    def initialize(configuration)
      @configuration = configuration
    end

    # Sequentially step through all of the available initialization routines,
    # in order (view execution order in source).
    def process
      load_environment
      load_logger

      start_initialization_process_log

      set_load_path
      add_gem_load_paths

      set_autoload_paths
      load_framework_adapter

      load_gems
      load_plugins

      # pick up any gems that plugins depend on
      add_gem_load_paths
      load_gems
      check_gem_dependencies

      # bail out if gems are missing - note that check_gem_dependencies will have
      # already called abort() unless $gems_rake_task is set
      return unless gems_dependencies_loaded

      finish_initialization_process_log
     end

    # Set the <tt>$LOAD_PATH</tt> based on the value of
    # Configuration#load_paths. Duplicates are removed.
    def set_load_path
      load_paths = configuration.load_paths
      load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) }
      $LOAD_PATH.uniq!
    end

    # Set the paths from which RuGUI will automatically load source files.
    def set_autoload_paths
      ActiveSupport::Dependencies.autoload_paths = configuration.load_paths.uniq
    end

    # Loads the environment specified by Configuration#environment_path, which
    # is typically one of development, or production.
    def load_environment
      return if @environment_loaded
      @environment_loaded = true

      if File.exist?(configuration.environment_path)
        config = configuration
        constants = self.class.constants

        eval(IO.read(configuration.environment_path), binding, configuration.environment_path)

        (self.class.constants - constants).each do |const|
          Object.const_set(const, self.class.const_get(const))
        end
      end
    end

    def load_plugins
      plugin_loader.load_plugins
    end

    def add_gem_load_paths
      RuGUI::GemDependency.add_frozen_gem_path
      unless @configuration.gems.empty?
        require "rubygems"
        @configuration.gems.each { |gem| gem.add_load_paths }
      end
    end

    def load_gems
      unless $gems_build_rake_task
        @configuration.gems.each { |gem| gem.load }
      end
    end

    def check_gem_dependencies
      unloaded_gems = @configuration.gems.reject { |g| g.loaded? }
      if unloaded_gems.size > 0
        @gems_dependencies_loaded = false
        # don't print if the gems rake tasks are being run
        unless $gems_rake_task
          abort <<-end_error
Missing these required gems:
  #{unloaded_gems.map { |gem| "#{gem.name}  #{gem.requirement}" } * "\n  "}

You're running:
  ruby #{Gem.ruby_version} at #{Gem.ruby}
  rubygems #{Gem::RubyGemsVersion} at #{Gem.path * ', '}

Run `rake gems:install` to install the missing gems.
          end_error
        end
      else
        @gems_dependencies_loaded = true
      end
    end

    def load_logger
      RuGUILogger.logger
    end

    def start_initialization_process_log
      logger.info "Starting RuGUI application with #{configuration.environment} environment..." unless silence_logs?
    end

    def finish_initialization_process_log
      logger.info "RuGUI application configurations loaded." unless silence_logs?
    end

    def plugin_loader
      @plugin_loader || RuGUI::Plugin::Loader.new(self, configuration)
    end

    def load_framework_adapter
      require "rugui/framework_adapters/#{RuGUI.configuration.framework_adapter}"
    end

    private
      def silence_logs?
        @@processed or $gems_build_rake_task or $gems_rake_task
      end
  end
end

