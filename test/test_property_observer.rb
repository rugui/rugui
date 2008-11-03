require 'test_helper'

class FakeObservableForPropertyObserverTest
  include RuGUI::ObservablePropertySupport
  
  observable_property :my_observable_property
  
  def to_s
    self.class.name
  end
end

class FakeObserverForPropertyObserverTest
  include RuGUI::PropertyObserver
  
  attr_accessor :property_updated_message
  attr_accessor :class_specific_method_called_message
  attr_accessor :instance_specific_method_called_message
  attr_accessor :observable
  attr_accessor :named_observable
  
  def initialize
    @observable = FakeObservableForPropertyObserverTest.new
    @observable.register_observer(self)
    
    @named_observable = FakeObservableForPropertyObserverTest.new
    @named_observable.register_observer(self, 'named_observable')
  end
  
  def value_to_s(value)
    if value.is_a?(Hash)
      value.keys.sort
    else
      value
    end
  end
  
  def property_my_observable_property_changed(observable, new_value, old_value)
    @property_updated_message = "#{observable} property my_observable_property changed from #{value_to_s(old_value)} to #{value_to_s(new_value)}"
  end
  
  def property_fake_observable_for_property_observer_test_my_observable_property_changed(observable, new_value, old_value)
    @class_specific_method_called_message = "Property my_observable_property changed, called from class specific method"
  end
  
  def property_named_observable_my_observable_property_changed(observable, new_value, old_value)
    @instance_specific_method_called_message = "Property my_observable_property changed, called from named instance specific method"
  end
end

class TestPropertyObserver < Test::Unit::TestCase
  def setup
    @observer = FakeObserverForPropertyObserverTest.new
  end
  
  def test_that_setting_a_value_in_the_observable_property_notifies_the_observer
    @observer.observable.my_observable_property = "something"
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from  to something", @observer.property_updated_message
    
    @observer.observable.my_observable_property = 1
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from something to 1", @observer.property_updated_message
    
    @observer.observable.my_observable_property = ["somearray"]
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from 1 to somearray", @observer.property_updated_message
    
    @observer.observable.my_observable_property = {'key' => "value"}
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from somearray to key", @observer.property_updated_message
  end
  
  def test_that_changing_a_value_in_the_observable_property_notifies_the_observer
    @observer.observable.my_observable_property = "something"
    @observer.observable.my_observable_property << "_else"
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from something to something_else", @observer.property_updated_message
    
    @observer.observable.my_observable_property = ["somearray"]
    @observer.observable.my_observable_property << "another_value"
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from somearray to somearrayanother_value", @observer.property_updated_message
    
    @observer.observable.my_observable_property = {'key' => "value"}
    @observer.observable.my_observable_property['another_key'] = "another_value"
    assert_equal "FakeObservableForPropertyObserverTest property my_observable_property changed from key to another_keykey", @observer.property_updated_message
  end
  
  def test_that_setting_the_same_value_again_in_the_observable_property_will_not_notifiy_the_observer
    set_same_value_twice_clearing_property_updated_message("something")
    assert_nil @observer.property_updated_message
    
    set_same_value_twice_clearing_property_updated_message(["somearray"])
    assert_nil @observer.property_updated_message
    
    set_same_value_twice_clearing_property_updated_message({'key' => "value"})
    assert_nil @observer.property_updated_message
  end
  
  def test_that_class_specific_method_gets_called_when_observable_property_changes
    @observer.observable.my_observable_property = "something"
    assert_equal "Property my_observable_property changed, called from class specific method", @observer.class_specific_method_called_message
    
    @observer.class_specific_method_called_message = nil
    
    @observer.observable.my_observable_property << "something"
    assert_equal "Property my_observable_property changed, called from class specific method", @observer.class_specific_method_called_message
  end

  def test_that_named_instance_specific_method_gets_called_when_observable_property_changes
    @observer.named_observable.my_observable_property = "something"
    assert_equal "Property my_observable_property changed, called from named instance specific method", @observer.instance_specific_method_called_message
    
    @observer.instance_specific_method_called_message = nil
    
    @observer.named_observable.my_observable_property << "something"
    assert_equal "Property my_observable_property changed, called from named instance specific method", @observer.instance_specific_method_called_message
  end
  
  protected
    def set_same_value_twice_clearing_property_updated_message(value)
      @observer.observable.my_observable_property = value
      @observer.property_updated_message = nil
      @observer.observable.my_observable_property = value
    end
end
