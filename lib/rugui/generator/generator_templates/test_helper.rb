$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'

# Forcing the 'test' environment.
ENV["RUGUI_ENV"] = "test"

require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

class Test::Unit::TestCase
  # Add more helper methods to be used by all tests here...
end