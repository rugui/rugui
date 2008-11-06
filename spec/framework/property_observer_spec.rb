require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'observables')

describe RuGUI::PropertyObserver do
  before(:each) do
    @observer = FakeObserverForPropertyObserverTest.new
  end
  
  describe "with notification" do
    it "should be notified when setting a new value in a observable property" do
      @observer.observable.my_observable_property = "something"
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from  to something"
      
      @observer.observable.my_observable_property = 1
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from something to 1"
      
      @observer.observable.my_observable_property = ["somearray"]
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from 1 to somearray"
      
      @observer.observable.my_observable_property = {'key' => "value"}
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from somearray to key"
    end
    
    it "should be notified when changing the value of a observable property" do
      @observer.observable.my_observable_property = "something"
      @observer.observable.my_observable_property << "_else"
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from something to something_else"
      
      @observer.observable.my_observable_property = ["somearray"]
      @observer.observable.my_observable_property << "another_value"
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from somearray to somearrayanother_value"
      
      @observer.observable.my_observable_property = {'key' => "value"}
      @observer.observable.my_observable_property['another_key'] = "another_value"
      @observer.property_updated_message.should == "FakeObservableForPropertyObserverTest property my_observable_property changed from key to another_keykey"
    end
    
    it "should not be notified when setting the same value in a observable property" do
      set_same_value_twice_clearing_property_updated_message("something")
      @observer.property_updated_message.should be_nil

      set_same_value_twice_clearing_property_updated_message(["somearray"])
      @observer.property_updated_message.should be_nil

      set_same_value_twice_clearing_property_updated_message({'key' => "value"})
      @observer.property_updated_message.should be_nil
    end
    
    def set_same_value_twice_clearing_property_updated_message(value)
      @observer.observable.my_observable_property = value
      @observer.property_updated_message = nil
      @observer.observable.my_observable_property = value
    end
  end
  
  describe "class specific methods" do
    it "should be called when observable property changes" do
      @observer.observable.my_observable_property = "something"
      @observer.class_specific_method_called_message.should == "Property my_observable_property changed, called from class specific method"

      # clearing message
      @observer.class_specific_method_called_message = nil

      @observer.observable.my_observable_property << "something"
      @observer.class_specific_method_called_message.should == "Property my_observable_property changed, called from class specific method"
    end
  end
  
  describe "named instance specific methods" do
    it "should be called when observable property changes" do
      @observer.named_observable.my_observable_property = "something"
      @observer.instance_specific_method_called_message.should == "Property my_observable_property changed, called from named instance specific method"

      # clearing message
      @observer.instance_specific_method_called_message = nil

      @observer.named_observable.my_observable_property << "something"
      @observer.instance_specific_method_called_message.should == "Property my_observable_property changed, called from named instance specific method"
    end
    
    it "should not be called when the instance name collides with the class name" do
      lambda {
        @observer.fake_named_observable_test.my_observable_property = "something"
      }.should change(@observer, :property_changed_counter).by(1) # Should call only the class method
    end
  end
end
