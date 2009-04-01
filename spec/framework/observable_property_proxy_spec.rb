require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'observables')

describe RuGUI::ObservablePropertyProxy do
  before(:each) do
    @observable = FakeObservable.new
    @custom_type = CustomType.new
    @custom_type.custom_property = "initial_value"
    
    @observable_properties = {
      :object => RuGUI::ObservablePropertyProxy.new(Object.new, @observable, :my_object_observable_property),
      :string => RuGUI::ObservablePropertyProxy.new("some_value", @observable, :my_string_observable_property),
      :fixnum => RuGUI::ObservablePropertyProxy.new(1, @observable, :my_fixnum_observable_property),
      :float => RuGUI::ObservablePropertyProxy.new(1.1, @observable, :my_float_observable_property),
      :array => RuGUI::ObservablePropertyProxy.new([], @observable, :my_array_observable_property),
      :hash => RuGUI::ObservablePropertyProxy.new({}, @observable, :my_hash_observable_property),
      :custom_type => RuGUI::ObservablePropertyProxy.new(@custom_type, @observable, :my_custom_type_observable_property),
    }
  end
  
  [:object, :string, :fixnum, :float, :array, :hash, :custom_type].each do |type|
    describe "with #{type.to_s.camelize} observable properties" do
      it "should work as proxy for #{type.to_s.camelize} methods" do
        @observable_properties[type].should be_an_instance_of(type.to_s.camelize.constantize)
        type.to_s.camelize.constantize.instance_methods.each do |method_name|
          @observable_properties[type].respond_to?(method_name).should be_true
        end
      end
    end
  end
  
  describe "with notification" do
    it "should notifiy the observable when calling methods that changes the observable property" do
      @observable_properties[:string].reverse! # reversing a string
      @observable.property_changed_message.should == "my_string_observable_property changed from some_value to eulav_emos"
      
      @observable_properties[:array] << 1 # adding an element into an array
      @observable.property_changed_message.should == "my_array_observable_property changed from  to 1"
      
      @observable_properties[:hash][:key] = "value" # setting or changing a value in a hash
      @observable.property_changed_message.should == "my_hash_observable_property changed from  to keyvalue"
      
      @observable_properties[:custom_type].change_custom_property("new_value") # calling a custom method which changes the property
      @observable.property_changed_message.should == "my_custom_type_observable_property changed from initial_value to new_value"

      @observable_properties[:custom_type].custom_property = "another_new_value" # changing a custom property with setter method
      @observable.property_changed_message.should == "my_custom_type_observable_property changed from new_value to another_new_value"
    end
    
    it "should not notifiy the observable when calling methods that does not changes the observable property" do
      @observable_properties[:string].reverse # reversing a string and returning a new copy of it
      @observable.property_changed_message.should be_nil
      
      @observable_properties[:array].index("some_value") # getting an element in the array
      @observable.property_changed_message.should be_nil
      
      @observable_properties[:hash].include?("some_key") # checking if a key is included in a hash
      @observable.property_changed_message.should be_nil
      
      @observable_properties[:custom_type].custom_method # calling a custom method which does not change
      @observable.property_changed_message.should be_nil

      @observable_properties[:custom_type].custom_method_with_parameters("something", "something else", "arg1", "arg2", "arg...") # calling a custom method which does not change
      @observable.property_changed_message.should be_nil
    end
  end
end
