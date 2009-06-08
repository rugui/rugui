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

    describe "with conventionally named controllers and views" do
      it "should automatically register a conventionally named view if it exists" do
        @conventionally_named_controller = ConventionallyNamedController.new
        @conventionally_named_controller.respond_to?(:conventionally_named_view).should be_true
        @conventionally_named_controller.conventionally_named_view.should be_an_instance_of(ConventionallyNamedView)
      end
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

  describe "with new style registering" do
    before :all do
      RuGUI.configuration.automatically_register_conventionally_named_views = false
    end

    after :all do
      RuGUI.configuration.automatically_register_conventionally_named_views = true
    end

    describe "of views" do
      before :each do
        NewStyleController.views :new_style_view
        @controller = NewStyleController.new
      end

      it "should have the new_style_view registered when instantiated" do
        @controller.views[:new_style_view].should be_an_instance_of(NewStyleView)
        @controller.new_style_view.should be_an_instance_of(NewStyleView)
        @controller.views[:new_style_view].should == @controller.new_style_view
      end
    end

    describe "of models" do
      before :each do
        NewStyleController.models :new_style_model
        @controller = NewStyleController.new
      end

      it "should have the new_style_model registered when instantiated" do
        @controller.models[:new_style_model].should be_an_instance_of(NewStyleModel)
        @controller.new_style_model.should be_an_instance_of(NewStyleModel)
        @controller.models[:new_style_model].should == @controller.new_style_model
      end
    end

    describe "of main models" do
      before :each do
        NewStyleController.main_models :new_style_model
        
        @main_controller = RuGUI::BaseMainController.new
        @main_controller.register_model :new_style_model
        @main_controller.register_controller :new_style_controller

        @controller = @main_controller.new_style_controller
      end

      it "should have the new_style_model registered when instantiated" do
        @controller.main_models[:new_style_model].should be_an_instance_of(NewStyleModel)
        @controller.new_style_model.should be_an_instance_of(NewStyleModel)
        @controller.main_models[:new_style_model].should == @controller.new_style_model
      end

      it "should use the same instance that was registered in the main controller" do
        @controller.new_style_model.object_id.should == @main_controller.new_style_model.object_id # object ids should be equals here
      end

      it "should raise an error if we register a main model which aren't register in the main controller" do
        lambda {
          @controller.register_main_model(:some_inexistent_model)
        }.should raise_error(NoMethodError)
      end
    end

    describe "of controllers" do
      before :each do
        NewStyleController.controllers :new_style_child_controller
        @controller = NewStyleController.new
      end

      it "should have the new_style_child_controller registered when instantiated" do
        @controller.controllers[:new_style_child_controller].should be_an_instance_of(NewStyleChildController)
        @controller.new_style_child_controller.should be_an_instance_of(NewStyleChildController)
        @controller.controllers[:new_style_child_controller].should == @controller.new_style_child_controller
      end
    end
  end

  describe "with initialization hooks" do
    it "should call before initialize and after initialize methods" do
      controller = MyController.new
      controller.before_initialize_called?.should be_true
      controller.after_initialize_called?.should be_true
    end
  end
end
