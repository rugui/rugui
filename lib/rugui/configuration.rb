# Defines the environment to be used by the application.
RUGUI_ENV = (ENV['RUGUI_ENV'] || 'development').dup unless defined?(RUGUI_ENV)

module RuGUI
  # Defines configurations for a RuGUI application.
  class Configuration
    # The application root path, defined by ::APPLICATION_ROOT
    attr_reader :root_path

    # The environment for this application.
    attr_accessor :environment

    # The specific logger to use. By default, a logger will be created and
    # initialized using #log_path and #log_level, but a programmer may
    # specifically set the logger to use via this accessor and it will be
    # used directly.
    attr_accessor :logger

    # An array of paths for glade files.
    attr_accessor :glade_files_paths

    # An array of paths which should be automaticaly loaded.
    attr_accessor :load_paths

    # An array of paths which should be searched for gtkrc styles files.
    #
    # It searchs for files which have the '.rc' extension or files which have
    # the string 'gtkrc' in its filename.
    #
    # The order in which the files are loaded is random, so do not rely on it.
    #
    # If you need to use absolute paths in a gtkrc file, such as set the pixmap
    # path, you can use "{ROOT_PATH}", which will be substituted by the
    # application root path when the file is read.
    attr_accessor :styles_paths

    # The timeout for queued calls. Useful when performing long tasks.
    attr_accessor :queue_timeout

    # A hash of application specific configurations.
    attr_accessor :application
    
    def initialize
      set_root_path!

      self.environment = default_environment
      self.load_paths = default_load_paths
      self.glade_files_paths = default_glade_files_paths
      self.styles_paths = default_styles_paths
      self.queue_timeout = default_queue_timeout
      self.logger = {}
      self.application = {}
    end

    # The path to the current environment's file (<tt>development.rb</tt>, etc.). By
    # default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def environment_path
      root_path.join('config', 'environments', "#{environment}.rb")
    end

    def set_root_path!
      raise 'APPLICATION_ROOT is not set' unless defined?(::APPLICATION_ROOT)
      raise 'APPLICATION_ROOT is not a directory' unless File.directory?(::APPLICATION_ROOT)

      @root_path = Pathname.new(File.expand_path(::APPLICATION_ROOT))
    end

    private
      def default_environment
        ::RUGUI_ENV
      end

      def default_load_paths
        paths = []

        paths.concat %w(
          app
          app/models
          app/controllers
          app/views
          app/views/helpers
          config
          lib
        ).map { |dir| root_path.join(dir) }.select { |dir| File.directory?(dir) }
      end

      def default_glade_files_paths
        [root_path.join('app', 'resources', 'glade')]
      end

      def default_styles_paths
        [root_path.join('app', 'resources', 'styles')]
      end

      def default_queue_timeout
        50
      end
  end
end
