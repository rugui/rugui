require 'activesupport'
require 'gtk2'
require 'rugui/configuration'
require 'rugui/log_support'

module RuGUI
  class Initializer
    include RuGUI::LogSupport

    # The configuration for this application.
    attr_reader :configuration
    
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
      set_autoload_paths
      set_styles_paths
      load_environment

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
      ActiveSupport::Dependencies.load_paths = configuration.load_paths.uniq
    end

    # Set the paths from which RuGUI will automatically load styles files,
    # i.e., gtkrc files.
    def set_styles_paths
      styles_paths = configuration.styles_paths.select { |path| File.directory?(path) }
      styles_paths.each do |path|
        styles_dir = Dir.new(path)
        styles_dir.each do |entry|
          Gtk::RC.parse_string(get_style_file_contents(path, entry)) if is_style_file?(path, entry)
        end
      end
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
    
    def load_logger
      initialize_logger(self.class.name, configuration.logger[:output], configuration.logger[:level], configuration.logger[:format]) unless @@processed
    end
    
    def start_initialization_process_log
      logger.info "Starting RuGUI application with #{configuration.environment} environment..." unless @@processed
    end
    
    def finish_initialization_process_log
      logger.info "RuGUI application configurations loaded." unless @@processed
    end

    private
      def is_style_file?(path, filename)
        if File.file?(File.join(path, filename))
          File.extname(filename) == '.rc' or /gtkrc/.match(filename)
        end
      end

      def get_style_file_contents(path, filename)
        IO.read(File.join(path, filename)).sub('{ROOT_PATH}', configuration.root_path)
      end
  end
end
