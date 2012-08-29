$:.unshift File.join(File.dirname(__FILE__),'..','lib')

# Forcing the 'test' environment.
ENV["RUGUI_ENV"] = "test"

require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

Spec::Runner.configure do |config|
  # Add spec runner configurations here.
end
