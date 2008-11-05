require 'spec'
require 'rubygems'

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rugui'

APPLICATION_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(APPLICATION_ROOT)

RuGUI.configuration = RuGUI::Configuration.new

Spec::Runner.configure do |config|
  # No configuration here yet.
end
