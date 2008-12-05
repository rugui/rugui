require 'logger'

module RuGUI
  #
  # A simple log support for registering problems, infos and debugs.
  #
  module LogSupport
    # Returns the logger object.
    def logger
      @logger ||= RuGUILogger.logger
      @logger.formatter = RuGUI::LogSupport::Formatter.new(self.class.name)
      @logger
    end
    
    private
      class Formatter
        def initialize(classname = nil)
          @classname = classname
        end

        def call(severity, timestamp, progname, msg)
          timestamp = timestamp.strftime(RuGUI.configuration.logger[:format] || "%Y-%m-%d %H:%M:%S")
          "#{timestamp} (#{severity}) (#{@classname}) #{msg}\n"
        end
      end
  end
  
  class RuGUILogger
    class << self
      def logger
        @@rugui_logger ||= RuGUILogger.new
        @@rugui_logger.logger
      end
    end
      
    def logger
      @@logger
    end
    
    private
      def initialize
        setup_logger
      end
    
      #
      # Setup a new log support object. If a problem occurs a logger is setted up
      # to warn level.
      #
      def setup_logger
        begin
          @@logger = Logger.new(defined_output)
          @@logger.level = defined_level
        rescue StandardError => e
          @@logger = Logger.new(STDERR)
          @@logger.level = LEVELS[:warn]
          @@logger.warn "Log support problems: The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
          @@logger.error "#{e} #{e.backtrace.join("\n")}"
        end
      end
      
      #
      # Defines a output based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_output
        output = RuGUI.configuration.logger[:output]
        if output.nil? or [:stdout, :stderr].include?(output)
          DEFAULT_OUTPUT
        else
          File.join(RuGUI.root, 'log', output)
        end
      end

      #
      # Defines a level based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_level
        level = RuGUI.configuration.logger[:level]
        unless level
          level = DEFAULT_LEVEL
        else
          level = LEVELS[level]
        end
        level
      end

      def defined_classname(classname)
        classname || self.class.name
      end
      
      LEVELS = {
        :debug => Logger::DEBUG,
        :info => Logger::INFO,
        :warn => Logger::WARN,
        :error => Logger::ERROR,
        :fatal => Logger::FATAL
      }
      
      #
      # Default values to the log support object - aka logger
      #
      DEFAULT_OUTPUT = STDOUT
      DEFAULT_LEVEL = LEVELS[:debug]
  end
end