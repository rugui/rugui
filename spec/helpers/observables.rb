# Defines some observables and custom types used in specs.

class FakeObservable < RuGUI::BaseObject
  attr_accessor :property_changed_message 

  def framework_adapter
    framework_adapter_for('BaseController')
  end

  def property_changed(property, new_value, old_value)
    self.property_changed_message = "#{property} changed from #{old_value} to #{new_value}"
  end
end

class AnotherFakeObserver < RuGUI::BaseObject
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

class AnotherFakeObservable < RuGUI::BaseObject
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

class SomeOtherFakeObservable < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :another_observable_property, :initial_value => "some_other_initial_value"
  observable_property :first_core_observable_property, :core => true, :initial_value => "first"
  observable_property :second_core_observable_property, :core => true, :initial_value => "second"
  
  def to_s
    self.class.name
  end
end

class CustomTypeFakeObservable < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :custom_type_observable_property, :core => true, :initial_value => AnotherFakeObservable.new
  
  def to_s
    self.class.name
  end
end

class ResetPreventedFakeObservable < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :reset_prevented_observable_property, :prevent_reset => true
  observable_property :reset_prevented_with_reset_value_observable_property, :reset_value => 'foo', :prevent_reset => true
  
  def to_s
    self.class.name
  end
end

class BooleanPropertiesFakeObservable < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :boolean_observable_property, :boolean => true
  observable_property :non_boolean_observable_property
  
  def to_s
    self.class.name
  end
end

class ParentFakeObservable < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :my_own_observable_property
  observable_property :child_observable_property
  
  def to_s
    self.class.name
  end
end

class ChildFakeObservable < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :my_observable_property, :core => true
  
  def to_s
    self.class.name
  end
end

class FakeObservableForPropertyObserverTest < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :my_observable_property
  
  def to_s
    self.class.name
  end
end

class FakeNamedObservableTest < RuGUI::BaseObject
  include RuGUI::ObservablePropertySupport
  
  observable_property :my_observable_property
  
  def to_s
    self.class.name
  end
end

class FakeObserverForPropertyObserverTest < RuGUI::BaseObject
  include RuGUI::PropertyObserver
  
  attr_accessor :property_updated_message
  attr_accessor :class_specific_method_called_message
  attr_accessor :instance_specific_method_called_message
  attr_accessor :instance_specific_method_called_counter
  attr_accessor :observable
  attr_accessor :named_observable
  attr_accessor :fake_named_observable_test
  
  attr_accessor :property_changed_counter
  
  def initialize
    @observable = FakeObservableForPropertyObserverTest.new
    @observable.register_observer(self)
    
    @named_observable = FakeObservableForPropertyObserverTest.new
    @named_observable.register_observer(self, 'named_observable')
    
    @fake_named_observable_test = FakeNamedObservableTest.new
    @fake_named_observable_test.register_observer(self, 'fake_named_observable_test')
    
    @property_changed_counter = 0
  end

  def framework_adapter
    framework_adapter_for('BaseController')
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
  
  def property_fake_named_observable_test_my_observable_property_changed(observable, new_value, old_value)
    @property_changed_counter += 1
  end
end

class CustomType < RuGUI::BaseObject
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