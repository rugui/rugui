require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'observables')

describe RuGUI::ObservablePropertySupport do
  before(:each) do
    @observable = AnotherFakeObservable.new
    @observer = AnotherFakeObserver.new
    @observable.register_observer(@observer)
  end
  
  describe "with notification" do
    it "should notify the observer when setting a new value in a observable property" do
      @observable.my_observable_property = "something"
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from  to something"
      
      @observable.my_observable_property = 1
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from something to 1"
      
      @observable.my_observable_property = ["somearray"]
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from 1 to somearray"
      
      @observable.my_observable_property = {'key' => "value"}
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from somearray to key"
    end
    
    it "should notify the observer when changing the value of a observable property" do
      @observable.my_observable_property = "something"
      @observable.my_observable_property << "_else"
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from something to something_else"
      
      @observable.my_observable_property = ["somearray"]
      @observable.my_observable_property << "another_value"
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from somearray to somearrayanother_value"
      
      @observable.my_observable_property = {'key' => "value"}
      @observable.my_observable_property['another_key'] = "another_value"
      @observer.property_updated_message.should == "AnotherFakeObservable property my_observable_property changed from key to another_keykey"
    end
    
    it "should not notify the observer when setting the same value in a observable property" do
      set_same_value_twice_clearing_property_updated_message("something")
      @observer.property_updated_message.should be_nil

      set_same_value_twice_clearing_property_updated_message(["somearray"])
      @observer.property_updated_message.should be_nil

      set_same_value_twice_clearing_property_updated_message({'key' => "value"})
      @observer.property_updated_message.should be_nil
    end
    
    def set_same_value_twice_clearing_property_updated_message(value)
      @observable.my_observable_property = value
      @observer.property_updated_message = nil
      @observable.my_observable_property = value
    end
  end
  
  describe "with CustomType observable properties" do
    it "should notify the observer when changing the CustomType instance changes" do
      custom_type_fake_observable = CustomTypeFakeObservable.new
      custom_type_fake_observable.register_observer(@observer)
      
      # Setting a value.
      custom_type_fake_observable.custom_type_observable_property.core_observable_property = "foo"
      
      # The observer must be notified, the message itself does not need to be meaniful
      @observer.property_updated_message.should == "CustomTypeFakeObservable property custom_type_observable_property changed from AnotherFakeObservable to AnotherFakeObservable"

      # Clearing the observer property_updated_message
      @observer.property_updated_message = nil

      # Reseting
      custom_type_fake_observable.reset!
      
      # The observer must be notified, the message itself does not need to be meaniful
      @observer.property_updated_message.should == "CustomTypeFakeObservable property custom_type_observable_property changed from AnotherFakeObservable to AnotherFakeObservable"
    end
  end
  
  describe "with observable property options" do
    it "should initialize properties configured with an initial value properly" do
      @observable.initialized_observable_property.should == "some_initial_value"
    end
    
    it "should set the configured reset_value when reseting an observable" do
      @observable.resetable_observable_property.should be_nil
      @observable.reset!
      @observable.resetable_observable_property.should == "some_reset_value"
    end
    
    it "should set the inital_value and the reset_value as appropriate" do
      @observable.initialized_and_resetable_observable_property.should == "some_initial_value"
      @observable.reset!
      @observable.initialized_and_resetable_observable_property.should == "some_reset_value"
    end
    
    it "should not be shared among different observable classes" do
      observable_properties_options = {
        :core_observable_property => { :core => true, :initial_value => "some_initial_value", :reset_value => "some_initial_value" },
        :initialized_observable_property => { :core => false, :initial_value => "some_initial_value", :reset_value => "some_initial_value" },
        :resetable_observable_property => { :core => false, :initial_value => nil, :reset_value => "some_reset_value" },
        :initialized_and_resetable_observable_property => { :core => false, :initial_value => "some_initial_value", :reset_value => "some_reset_value" },
        :my_observable_property => { :core => false, :initial_value => nil, :reset_value => nil },
        :my_array_observable_property => { :reset_value => [], :initial_value => [], :core => false },
        :my_hash_observable_property => { :reset_value => {}, :initial_value => {}, :core => false },
      }
      AnotherFakeObservable.observable_properties_options.should == observable_properties_options
    
      observable_properties_options = {
        :another_observable_property => {:core => false, :initial_value => "some_other_initial_value", :reset_value => "some_other_initial_value"},
        :first_core_observable_property => {:core => true, :initial_value => "first", :reset_value => "first"},
        :second_core_observable_property => {:core => true, :initial_value => "second", :reset_value => "second"},
      }
      SomeOtherFakeObservable.observable_properties_options.should == observable_properties_options
    end
    
    it "should not let initial_value and reset_value be modified when the property value changes" do
      AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:initial_value].should == []
      AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:reset_value].should == []

      AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:initial_value].should == {}
      AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:reset_value].should == {}

      @observable.my_array_observable_property << 1
      AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:initial_value].should == []
      AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:reset_value].should == []

      @observable.my_hash_observable_property[:foo] = 'bar'
      AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:initial_value].should == {}
      AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:reset_value].should == {}
    end
    
    it "should prevent properties from being reset if configured" do
      observable = ResetPreventedFakeObservable.new
      observable.reset_prevented_observable_property = 'bar'
      observable.reset!
      observable.reset_prevented_observable_property.should == 'bar'
    end
    
    it "should prevent properties from being reset even if a :reset_value was configured" do
      observable = ResetPreventedFakeObservable.new
      observable.reset_prevented_with_reset_value_observable_property = 'bar'
      observable.reset!
      observable.reset_prevented_with_reset_value_observable_property.should == 'bar'
    end
  end
  
  describe "with two instances comparison" do
    it "should be equals when all configured core observable properties are equals" do
      some_other_observable = AnotherFakeObservable.new
      some_other_observable.should == @observable
    end
    
    it "should not be equals when at least one of the configured core observable properties are not equals" do
      some_other_observable1 = SomeOtherFakeObservable.new
      some_other_observable1.first_core_observable_property = "different_value"
      some_other_observable2 = SomeOtherFakeObservable.new
      some_other_observable1.should_not == some_other_observable2

      some_other_observable1 = SomeOtherFakeObservable.new
      some_other_observable2 = SomeOtherFakeObservable.new
      some_other_observable2.first_core_observable_property = "different_value"
      some_other_observable1.should_not == some_other_observable2
    end
  end
end
