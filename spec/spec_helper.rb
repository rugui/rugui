require 'bundler/setup'

Bundler.require(:default, :test)

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rugui'
require 'rugui/initializer'

APPLICATION_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(APPLICATION_ROOT)

RuGUI::Initializer.run { |config| config.logger[:level] = :error }

Dir["spec/helpers/**/*.rb"].each { |file| load file }

RSpec.configure do |config|
  # No configuration here yet.
  config.before(:each) do
    HelperManager.clear!
  end
end
