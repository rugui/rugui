require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'controllers')
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'views')
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'models')

describe RuGUI::BaseController do
  before(:each) do
    @controller = MyController.new
  end
  
  describe "with view registering" do
    it "should make the view available in a views hash and in an attribute" do
      @controller.views[:my_view].should be_an_instance_of(MyView)
      @controller.my_view.should be_an_instance_of(MyView)
      @controller.views[:my_view].should == @controller.my_view
    end
  end
  
  describe "with model registering" do
    it "should make the model available in a models hash and in an attribute" do
      @controller.models[:my_model].should be_an_instance_of(MyModel)
      @controller.my_model.should be_an_instance_of(MyModel)
      @controller.models[:my_model].should == @controller.my_model
    end
    
    it "should be notified using named observable property change calls" do
      @controller.my_other_model_instance.my_property = 1
      @controller.message.should == "Property my_property of named observable my_other_model_instance changed from  to 1."
    end
  end
  
  describe "with controller registering" do
    it "should make the controller available in a controllers hash and in an attribute" do
      @controller.controllers[:my_child_controller].should be_an_instance_of(MyChildController)
      @controller.my_child_controller.should be_an_instance_of(MyChildController)
      @controller.controllers[:my_child_controller].should == @controller.my_child_controller
    end
  end
end
