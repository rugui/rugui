# Uncomment below to force the RuGUI application into production mode
# ENV['RUGUI_ENV'] ||= 'production'

# Bootstrap the RuGUI environment, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

RuGUI::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See RuGUI::Configuration for more options.

  # Changes the framework adapter. Currently the only implemented framework
  # adapters are GTK and Qt4. Defaults to GTK.
  config.framework_adapter = 'Qt4'

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{APPLICATION_ROOT}/extras )

  # The log output, by default it is :stdout, but can be :stderr or any valid
  # filename. Defaults to :stdout.
  #config.logger[:output] = :stdout

  # The level for logging. You can use :debug, :info, :warn, :error or :fatal
  # That is the sequence of severity. Defaults to :info.
  #config.logger[:level] = :info

  # The format of timestamp. See the formatting for Time.strftime
  #
  # See with more details here:
  # http://www.rubybrain.com/api/ruby-1.8.7/doc/index.html?a=M000253&name=strftime
  #config.logger[:format] = "%Y-%m-%d %H:%M:%S"
end
