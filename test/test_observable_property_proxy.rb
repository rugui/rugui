require 'test_helper'

class FakeObservable
  attr_accessor :property_changed_message 
  
  def property_changed(property, new_value, old_value)
    self.property_changed_message = "#{property} changed from #{old_value} to #{new_value}"
  end
end

class CustomType
  attr_accessor :custom_property

  def custom_method
    "foo"
  end
  
  def custom_method_with_parameters(first_param, second_param, *args)
    "#{first_param}, #{second_param}, #{args.join(', ')}"
  end
  
  def change_custom_property(new_value)
    @custom_property = new_value
  end
  
  def ==(obj)
    obj.is_a?(CustomType) and obj.custom_property == self.custom_property
  end
  
  def to_s
    self.custom_property
  end
end

class TestObservablePropertyProxy < Test::Unit::TestCase
  def setup
    @observable = FakeObservable.new
    @custom_type = CustomType.new
    @custom_type.custom_property = "initial_value"
    
    @my_object_observable_property = RuGUI::ObservablePropertyProxy.new(Object.new, @observable, :my_object_observable_property)
    @my_string_observable_property = RuGUI::ObservablePropertyProxy.new("some_value", @observable, :my_string_observable_property)
    @my_fixnum_observable_property = RuGUI::ObservablePropertyProxy.new(1, @observable, :my_fixnum_observable_property)
    @my_float_observable_property = RuGUI::ObservablePropertyProxy.new(1.1, @observable, :my_float_observable_property)
    @my_array_observable_property = RuGUI::ObservablePropertyProxy.new([], @observable, :my_array_observable_property)
    @my_hash_observable_property = RuGUI::ObservablePropertyProxy.new({}, @observable, :my_hash_observable_property)
    @my_custom_type_observable_property = RuGUI::ObservablePropertyProxy.new(@custom_type, @observable, :my_custom_type_observable_property)
  end
  
  def test_my_object_observable_property_works_as_proxy_for_object_methods
    assert_instance_of Object, @my_object_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_object_observable_property, Object)
  end
  
  def test_my_string_observable_property_works_as_proxy_for_string_methods
    assert_instance_of String, @my_string_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_string_observable_property, String)
  end
  
  def test_my_fixnum_observable_property_works_as_proxy_for_fixnum_methods
    assert_instance_of Fixnum, @my_fixnum_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_fixnum_observable_property, Fixnum)
  end
  
  def test_my_float_observable_property_works_as_proxy_for_float_methods
    assert_instance_of Float, @my_float_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_float_observable_property, Float)
  end
  
  def test_my_array_observable_property_works_as_proxy_for_array_methods
    assert_instance_of Array, @my_array_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_array_observable_property, Array)
  end
  
  def test_my_hash_observable_property_works_as_proxy_for_hash_methods
    assert_instance_of Hash, @my_hash_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_hash_observable_property, Hash)
  end
  
  def test_my_custom_type_observable_property_works_as_proxy_for_custom_type_methods
    assert_instance_of CustomType, @my_custom_type_observable_property
    check_observable_property_proxy_respond_to_instance_methods(@my_custom_type_observable_property, CustomType)
  end
  
  def test_that_calling_methods_that_changes_the_observable_property_proxy_notifies_observable
    @my_string_observable_property.reverse!
    assert_equal "my_string_observable_property changed from some_value to eulav_emos", @observable.property_changed_message
    
    @my_array_observable_property << 1
    assert_equal "my_array_observable_property changed from  to 1", @observable.property_changed_message
    
    @my_hash_observable_property[:key] = "value"
    assert_equal "my_hash_observable_property changed from  to keyvalue", @observable.property_changed_message
    
    @my_custom_type_observable_property.change_custom_property("new_value")
    assert_equal "my_custom_type_observable_property changed from initial_value to new_value", @observable.property_changed_message
    
    @my_custom_type_observable_property.custom_property = "another_new_value"
    assert_equal "my_custom_type_observable_property changed from new_value to another_new_value", @observable.property_changed_message
  end
  
  def test_that_calling_methods_that_does_not_change_the_observable_property_proxy_does_not_notify_observable
    @my_string_observable_property.reverse
    assert_nil @observable.property_changed_message
    
    @my_array_observable_property.index("some_value")
    assert_nil @observable.property_changed_message
    
    @my_hash_observable_property.include?("some_key")
    assert_nil @observable.property_changed_message
    
    @my_custom_type_observable_property.custom_method
    assert_nil @observable.property_changed_message
    
    @my_custom_type_observable_property.custom_method_with_parameters("something", "something else", "arg1", "arg2", "arg...")
    assert_nil @observable.property_changed_message
  end
  
  protected
    def check_observable_property_proxy_respond_to_instance_methods(observable_property_proxy, klass)
      klass.instance_methods.each do |method_name|
        assert observable_property_proxy.respond_to?(method_name), "#{klass} ObservablePropertyProxy does not respond_to: #{method_name}"
      end
    end
end
