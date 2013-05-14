module RuGUI
  # A proxy class for observable properties.
  #
  # When creating an <code>ObservablePropertyProxy</code> you pass an
  # instance of any object to it (which will now be the context for this
  # proxy), the observable and the property name.
  #
  # The <code>ObservablePropertyProxy</code> instance will work as a
  # proxy for each method send to the context. If the context is changed,
  # it will notify any <code>PropertyObservers</code> registered for its
  # <code>observable</code>, by calling their
  # <code>property_changed</code> method.
  #
  # CAUTION: When using observable string properties as keys in a Hash make
  # sure you call the Object#to_s or Object#to_sym methods before putting
  # the property value as key. Hashes uses the method Object#eql? when
  # comparing keys, and for some unknown reason it is always returning false
  # when comparing observable string properties.
  #
  class ObservablePropertyProxy < BaseObject
    include RuGUI::LogSupport

    def initialize(context, observable, property)
      @context = context
      @observable = observable
      @property = property
    end

    private
      NON_DELEGATABLE_METHODS = ['__id__', '__send__', 'object_id']

      # Delegating Object's methods to context. Since none of these methods
      # really change the object we just send them to the context.
      self.methods.each do |method_name|
        unless NON_DELEGATABLE_METHODS.include?(method_name.to_s)
          self.class_eval <<-class_eval
            def #{method_name}(*args)
              @context.send(:#{method_name}, *args)
            end
          class_eval
        end
      end

      # Here we reimplement the method missing, adding code to notify observers
      # when the property has changed, i.e., when the context before calling the
      # method is different than the context after the method is called.
      def method_missing(method, *args, &block)
        old_context = get_context_copy
        return_value = @context.send(method, *args, &block)

        context_changed(@context, old_context) unless @context == old_context
        return_value
      end

      # Returns a copy of the context.
      def get_context_copy
        begin
          return @context.clone
        rescue TypeError
          return @context
        end
      end

      #
      # Called when the context has changed.
      #
      # Notifies all registered observers
      #
      def context_changed(new_value, old_value)
        @observable.property_changed(@property, new_value, old_value)
      end
  end
end
