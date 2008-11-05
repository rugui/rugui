# Defines some observables and custom types used in specs.

class FakeObservable
  attr_accessor :property_changed_message 
  
  def property_changed(property, new_value, old_value)
    self.property_changed_message = "#{property} changed from #{old_value} to #{new_value}"
  end
end

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