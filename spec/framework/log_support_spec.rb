require 'spec_helper'

class MyObjectWithLogSupport
  include RuGUI::LogSupport
end

describe RuGUI::LogSupport do
  before(:each) do
    @my_object_with_log_support = MyObjectWithLogSupport.new
  end

  it "should have a default logger if it is not initialized" do
    @my_object_with_log_support.respond_to?(:logger).should be_true
    @my_object_with_log_support.logger.should be_an_instance_of(Logger)
  end
end
