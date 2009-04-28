module RuGUI
  # Adds observer functionality for any class which has support for observable
  # properties.
  #
  # The observer class should implement a method name
  # 'property_property_name_changed', where 'property_name' is
  # the name of the observable property, that will be called whenever that
  # property value has changed. If it does not declare a method with this
  # name, it will be silently ignored.
  #
  # The method signature is:
  #
  #   property_foo_changed(model, new_value, old_value)
  #
  # for a property named 'foo'.
  #
  # If the observer class declares a method with this signature:
  #
  #   property_my_class_foo_changed(model, new_value, old_value)
  #
  # it will be called whenever the property _foo_ of an observable of the
  # class <code>MyClass</code> has changed.
  #
  # Also, if the observer class declares a method with this signature:
  #
  #   property_my_named_observable_foo_changed(model, new_value, old_value)
  #
  # it will be called whenever the property _foo_ of the observable named
  # _my_named_observable_ has changed. To declare named observers, you must
  # register the observer passing a name to the
  # ObservablePropertySupport#register_observer method.
  #
  module PropertyObserver
    include RuGUI::FrameworkAdapters::FrameworkAdapterSupport

    def property_updated(observable, property, new_value, old_value)
      queue_method_call_if_exists("property_#{property}_changed", observable, new_value, old_value)
      queue_method_call_if_exists("property_#{observable.class.name.underscore}_#{property}_changed", observable, new_value, old_value)
      self.property_changed_blocks.each do |property_changed_block|
        property_changed_block.call_property_changed_block_if_exists(observable, property, new_value, old_value)
      end
    end

    def named_observable_property_updated(observable_name, observable, property, new_value, old_value)
      queue_method_call_if_exists("property_#{observable_name}_#{property}_changed", observable, new_value, old_value) unless named_observable_collides_with_class_name?(observable_name, observable)
    end

    private
      def queue_method_call_if_exists(method_name, *args)
        if respond_to?(method_name)
          logger.warn "This way of listening changed properties is deprecated. Please, take a look at when_property_changed method."
          self.framework_adapter.queue do
            send(method_name, *args)
          end
        end
      end

      def named_observable_collides_with_class_name?(observable_name, observable)
        observable_name == observable.class.name.underscore
      end
  end
end
