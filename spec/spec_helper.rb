require 'rubygems'
require 'spec'

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rugui'
require 'rugui/initializer'

APPLICATION_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(APPLICATION_ROOT)

RuGUI::Initializer.run { |config| }

Spec::Runner.configure do |config|
  # No configuration here yet.
end
