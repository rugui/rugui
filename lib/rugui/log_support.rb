require 'logger'

module RuGUI
  #
  # A simple log support for registering problems, infos and debugs.
  #
  module LogSupport
    #
    # Allows initialize the log support, setting up the class name that invokes the logger,
    # output, level and the format of the message.
    #
    def initialize_logger(classname = nil, output = nil, level = nil, format = nil)
      @logger = setup_logger(classname, output, level, format)
    end

    #
    # Invokes the log support object
    #
    def logger
      @logger || setup_logger
    end

    protected
      #
      # Setup a new log support object. If a problem occurs a logger is setted up
      # to warn level.
      #
      def setup_logger(classname = nil, output = nil, level = nil, format = nil)
        begin
          logr = Logger.new(defined_output(output))
          logr.level = defined_level(level)
          logr.classname = defined_classname(classname)

        rescue StandardError => e
          logr = Logger.new(OUTPUTS[:stderr])
          logr.level = LEVELS[:warn]
          logr.datetime_format = defined_format(format)
          logr.warn "Log support problems: The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
        end
        logr
      end

      #
      # Defines a output based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_output(output)
        unless output
          setted = RuGUI.configuration.logger[:output]
          output = setted ? OUTPUTS[setted] : DEFAULT_OUTPUT
        else
          output = output.is_a?(String) ? File.join('log', output) : OUTPUTS[output]
        end
        output
      end

      #
      # Defines a level based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_level(level)
        unless level
          setted = RuGUI.configuration.logger[:level]
          level = setted ? LEVELS[setted] : DEFAULT_LEVEL
        else
          level = LEVELS[level]
        end
        level
      end

      #
      # Defines a format based on params informed by user, params setted up in
      # the configuration file, or default values.
      #
      def defined_format(format)
        unless format
          format = (RuGUI.configuration.logger[:format] || DEFAULT_FORMAT)
        end
        format
      end

      def defined_classname(classname)
        classname || self.class.name
      end

    private
      #
      # Default values to levels
      #
      LEVELS = {
        :debug => Logger::DEBUG,
        :info => Logger::INFO,
        :warn => Logger::WARN,
        :error => Logger::ERROR,
        :fatal => Logger::FATAL
      }

      #
      # Default values to outputs
      #
      OUTPUTS = {
        :stdout => STDOUT,
        :stderr => STDERR,
        :file => ''
      }

      #
      # Default values to the log support object - aka logger
      #
      DEFAULT_OUTPUT = OUTPUTS[:stdout]
      DEFAULT_LEVEL = LEVELS[:debug]
      DEFAULT_FORMAT = "%Y-%m-%d %H:%M:%S"
  end
end

class Logger
  attr_accessor :classname

  #
  # Hack Hack Hack
  #
  def format_message(severity, timestamp, progname, msg)
    timestamp = timestamp.strftime(RuGUI.configuration.logger[:format] || "%Y-%m-%d %H:%M:%S")
    "#{timestamp} (#{severity}) (#{classname}) #{msg}\n"
  end
end
