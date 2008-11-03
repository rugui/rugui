require 'test_helper'

class AnotherFakeObserver
  attr_accessor :property_updated_message
  
  def value_to_s(value)
    if value.is_a?(Hash)
      value.keys.sort
    else
      value
    end
  end
  
  def property_updated(observable, property, new_value, old_value)
    
    @property_updated_message = "#{observable} property #{property} changed from #{value_to_s(old_value)} to #{value_to_s(new_value)}"
  end
end

class AnotherFakeObservable
  include RuGUI::ObservablePropertySupport
  
  observable_property :my_observable_property
  observable_property :my_array_observable_property, :initial_value => []
  observable_property :my_hash_observable_property, :initial_value => {}
  observable_property :initialized_observable_property, :initial_value => "some_initial_value"
  observable_property :resetable_observable_property, :reset_value => "some_reset_value"
  observable_property :initialized_and_resetable_observable_property, :initial_value => "some_initial_value", :reset_value => "some_reset_value"
  observable_property :core_observable_property, :core => true, :initial_value => "some_initial_value"
  
  def to_s
    self.class.name
  end
end

class SomeOtherFakeObservable
  include RuGUI::ObservablePropertySupport
  
  observable_property :another_observable_property, :initial_value => "some_other_initial_value"
  observable_property :first_core_observable_property, :core => true, :initial_value => "first"
  observable_property :second_core_observable_property, :core => true, :initial_value => "second"
  
  def to_s
    self.class.name
  end
end

class CustomTypeFakeObservable
  include RuGUI::ObservablePropertySupport
  
  observable_property :custom_type_observable_property, :core => true, :initial_value => AnotherFakeObservable.new
  
  def to_s
    self.class.name
  end
end

class TestObservablePropertySupport < Test::Unit::TestCase
  def setup
    @observable = AnotherFakeObservable.new
    @observer = AnotherFakeObserver.new
    @observable.register_observer(@observer)
  end
  
  def test_that_setting_a_value_in_the_observable_property_notifies_the_observer
    @observable.my_observable_property = "something"
    assert_equal "AnotherFakeObservable property my_observable_property changed from  to something", @observer.property_updated_message
    
    @observable.my_observable_property = 1
    assert_equal "AnotherFakeObservable property my_observable_property changed from something to 1", @observer.property_updated_message
    
    @observable.my_observable_property = ["somearray"]
    assert_equal "AnotherFakeObservable property my_observable_property changed from 1 to somearray", @observer.property_updated_message
    
    @observable.my_observable_property = {'key' => "value"}
    assert_equal "AnotherFakeObservable property my_observable_property changed from somearray to key", @observer.property_updated_message
  end
  
  def test_that_changing_a_value_in_the_observable_property_notifies_the_observer
    @observable.my_observable_property = "something"
    @observable.my_observable_property << "_else"
    assert_equal "AnotherFakeObservable property my_observable_property changed from something to something_else", @observer.property_updated_message
    
    @observable.my_observable_property = ["somearray"]
    @observable.my_observable_property << "another_value"
    assert_equal "AnotherFakeObservable property my_observable_property changed from somearray to somearrayanother_value", @observer.property_updated_message
    
    @observable.my_observable_property = {'key' => "value"}
    @observable.my_observable_property['another_key'] = "another_value"
    assert_equal "AnotherFakeObservable property my_observable_property changed from key to another_keykey", @observer.property_updated_message
  end
  
  def test_that_setting_the_same_value_again_in_the_observable_property_will_not_notifiy_the_observer
    set_same_value_twice_clearing_property_updated_message("something")
    assert_nil @observer.property_updated_message
    
    set_same_value_twice_clearing_property_updated_message(["somearray"])
    assert_nil @observer.property_updated_message
    
    set_same_value_twice_clearing_property_updated_message({'key' => "value"})
    assert_nil @observer.property_updated_message
  end
  
  def test_that_initialized_observable_property_was_properly_initialized
    assert_equal "some_initial_value", @observable.initialized_observable_property
  end
  
  def test_that_resetable_observable_property_is_properly_reset
    assert_nil @observable.resetable_observable_property
    @observable.reset!
    assert_equal "some_reset_value", @observable.resetable_observable_property
  end
  
  def test_that_initialized_and_resetable_observable_property_is_properly_initialized_and_reset
    assert_equal "some_initial_value", @observable.initialized_and_resetable_observable_property
    @observable.reset!
    assert_equal "some_reset_value", @observable.initialized_and_resetable_observable_property
  end
  
  def test_that_two_instances_are_equals_if_their_core_observable_property_are_equals
    some_other_observable = AnotherFakeObservable.new
    assert_equal some_other_observable, @observable
  end
  
  def test_that_two_instances_are_not_equals_if_their_core_observable_property_are_not_equals
    some_other_observable = AnotherFakeObservable.new
    some_other_observable.core_observable_property = "some_other_value"
    assert_not_equal some_other_observable, @observable
  end
  
  def test_that_two_instances_are_equals_if_all_their_core_observable_property_are_equals
    some_other_observable1 = SomeOtherFakeObservable.new
    some_other_observable2 = SomeOtherFakeObservable.new
    assert_equal some_other_observable1, some_other_observable2
  end
  
  def test_that_two_instances_are_not_equals_if_at_least_one_of_their_core_observable_property_are_not_equals
    some_other_observable1 = SomeOtherFakeObservable.new
    some_other_observable1.first_core_observable_property = "different_value"
    some_other_observable2 = SomeOtherFakeObservable.new
    assert_not_equal some_other_observable1, some_other_observable2
    
    some_other_observable1 = SomeOtherFakeObservable.new
    some_other_observable2 = SomeOtherFakeObservable.new
    some_other_observable2.first_core_observable_property = "different_value"
    assert_not_equal some_other_observable1, some_other_observable2
  end
  
  def test_that_observable_properties_options_are_not_shared_among_different_observable_classes
    observable_properties_options = {
      :core_observable_property => { :core => true, :initial_value => "some_initial_value", :reset_value => "some_initial_value" },
      :initialized_observable_property => { :core => false, :initial_value => "some_initial_value", :reset_value => "some_initial_value" },
      :resetable_observable_property => { :core => false, :initial_value => nil, :reset_value => "some_reset_value" },
      :initialized_and_resetable_observable_property => { :core => false, :initial_value => "some_initial_value", :reset_value => "some_reset_value" },
      :my_observable_property => { :core => false, :initial_value => nil, :reset_value => nil },
      :my_array_observable_property => { :reset_value => [], :initial_value => [], :core => false },
      :my_hash_observable_property => { :reset_value => {}, :initial_value => {}, :core => false },
    }
    assert_equal observable_properties_options, AnotherFakeObservable.observable_properties_options
    
    observable_properties_options = {
      :another_observable_property => {:core => false, :initial_value => "some_other_initial_value", :reset_value => "some_other_initial_value"},
      :first_core_observable_property => {:core => true, :initial_value => "first", :reset_value => "first"},
      :second_core_observable_property => {:core => true, :initial_value => "second", :reset_value => "second"},
    }
    assert_equal observable_properties_options, SomeOtherFakeObservable.observable_properties_options
  end
  
  def test_custom_type_observable_property_works_as_expected
    custom_type_fake_observable = CustomTypeFakeObservable.new
    custom_type_fake_observable.register_observer(@observer)
    custom_type_fake_observable.custom_type_observable_property.core_observable_property = "foo"
    # The observer must be notified, the message itself does not need to be meaniful
    assert_equal "CustomTypeFakeObservable property custom_type_observable_property changed from AnotherFakeObservable to AnotherFakeObservable", @observer.property_updated_message
    
    @observer.property_updated_message = nil
    
    custom_type_fake_observable.reset!
    # The observer must be notified, the message itself does not need to be meaniful
    assert_equal "CustomTypeFakeObservable property custom_type_observable_property changed from AnotherFakeObservable to AnotherFakeObservable", @observer.property_updated_message
  end
  
  def test_that_changing_observable_property_by_calling_a_method_will_not_interfere_with_initial_and_reset_values
    assert_equal [], AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:initial_value]
    assert_equal [], AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:reset_value]
    
    assert_equal({}, AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:initial_value])
    assert_equal({}, AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:reset_value])
    
    @observable.my_array_observable_property << 1
    assert_equal [], AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:initial_value]
    assert_equal [], AnotherFakeObservable.observable_properties_options[:my_array_observable_property][:reset_value]
    
    @observable.my_hash_observable_property[:foo] = 'bar'
    assert_equal({}, AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:initial_value])
    assert_equal({}, AnotherFakeObservable.observable_properties_options[:my_hash_observable_property][:reset_value])
  end
  
  protected
    def set_same_value_twice_clearing_property_updated_message(value)
      @observable.my_observable_property = value
      @observer.property_updated_message = nil
      @observable.my_observable_property = value
    end
end
