require 'rugui/observable_property_proxy'

module RuGUI
  # Adds support to observable properties.
  module ObservablePropertySupport
    # Initializes the observable properties. If you override this method, make
    # sure to call the <code>initialize_observable_property_support</code>
    # method, so that observable properties gets initialized.
    def initialize
      initialize_observable_property_support
    end
    
    # Initializes observable properties, setting their initial value.
    def initialize_observable_property_support
      self.class.observable_properties_options.each do |property, options|
        send("#{property}=", clone_if_possible(options[:initial_value]))
      end
    end
    
    # Registers an observer for this model.
    # 
    # The observer must implement a method with this signature:
    # 
    #   property_updated(observable, property, new_value, old_value)
    # 
    # This method is called whenever a property has changed its value. One
    # option is to include the PropertyObserver module in the observer class.
    # 
    # Optionally, if <code>observable_name</code> can be given, a method with
    # this signature will also be called:
    # 
    #   named_observable_property_updated(observable_name, observable, property, new_value, old_value)
    # 
    def register_observer(observer, observable_name = nil)
      initialize_observers_if_needed
      @observers << observer
      @named_observers[observable_name] = observer unless observable_name.nil?
    end

    # Called whenver the a property has changed.
    def property_changed(property, new_value, old_value)
      initialize_observers_if_needed
      @observers.each do |observer|
        observer.property_updated(self, property, new_value, old_value) if observer.respond_to?(:property_updated)
      end
      @named_observers.each do |observable_name, observer|
        observer.named_observable_property_updated(observable_name, self, property, new_value, old_value) if observer.respond_to?(:named_observable_property_updated)
      end
    end
    
    # Resets all observable properties for this observer.
    #
    # Since an observable property may be another observable there may exist
    # some observers observing this other observable. In this scenario one
    # should not attempt to set a new object into the observable property,
    # because the observers would still be looking for the old observable.
    # 
    # By calling <code>reset!</code> all observable properties are reset to the
    # values specified when creating it. Also if the property respond to reset
    # the method will be called, unless the *reset_value*, specified when
    # declaring the observable property, is not <code>nil</code>.
    def reset!
      self.class.observable_properties_options.each do |property, options|
        property_value = send(property)
        if options[:reset_value].nil? and property_value.respond_to?(:reset!)
          property_value.reset!
        else
          send("#{property}=", clone_if_possible(options[:reset_value]))
        end
      end
    end
    
    # Returns <code>true</code> if <code>obj</code> is equals to
    # <code>self</code>.
    #
    # This method checks if <code>obj</code> is of the same type of
    # <code>self</code> and if all *core* observable_properties are equals.
    def ==(obj)
      if obj.is_a?(self.class)
        self.class.core_observable_properties.each do |property|
          return false unless obj.respond_to?(property) and respond_to?(property)
          return false unless send(property) == obj.send(property)
        end
        return true
      end
    end

    module ClassMethods
      # Register one or more observable properties for this model.
      # 
      # Properties may be given as symbols, or strings. You can pass some
      # options, in a hash, which will be used when the observable is created:
      # 
      # - *initial_value*: The initial value for the property. This value will
      # be set when the observable instance is initialized (i.e., when the
      # <code>initialize</code> method is called). Defaults to <code>nil</code>.
      # - *reset_value*: The reset value for the property. This value will be
      # set when the observable instance is reset (i.e., when the
      # <code>reset</code> method is called). If this is not given the
      # <code>initial_value</code> will be used instead.
      # - *core*: Defines whether the property should be used when comparing two
      # observables. Defaults to <code>false</code>.
      # 
      # Examples:
      # 
      #   class MyObservable
      #     include RuGUI::ObservablePropertySupport
      #     
      #     observable_property :foo, :initial_value => "bar"
      #     observable_property :bar, :initial_value => "foo", :reset_value => "bar"
      #     observable_property :core_property, :core => true
      #     
      #     # And so on...
      #   end
      def observable_property(property, options = {})
        initialize_observable_properties_if_needed
        create_observable_property_options(property, options)
        create_observable_property_accessors(property)
      end
      
      # Returns the names of core observable properties for this class.
      def core_observable_properties
        core_observable_properties = []
        observable_properties_options.each do |property, options|
          core_observable_properties << property if options[:core] == true
        end
        core_observable_properties
      end

      # Returns a hash, keyed by the property name, with the options of
      # observable properties for this class.
      def observable_properties_options
        klass_observable_properties = {}
        if defined?(@@observable_properties_options) and not @@observable_properties_options.nil?
          klass_observable_properties = @@observable_properties_options[self.name.to_sym] if @@observable_properties_options.include?(self.name.to_sym)
        end
        klass_observable_properties
      end
      
      private
        def initialize_observable_properties_if_needed
          @@observable_properties_options = {} if not defined?(@@observable_properties_options) or @@observable_properties_options.nil?
          @@observable_properties_options[self.name.to_sym] = {} unless @@observable_properties_options.include?(self.name.to_sym)
        end
        
        def create_observable_property_options(property, options = {})
          @@observable_properties_options[self.name.to_sym][property.to_sym] = prepare_options(options)
        end
      
        def create_observable_property_accessors(property)
          self.class_eval <<-class_eval
            def #{property}
              @#{property}
            end

            def #{property}=(value)
              old_value = get_old_value(@#{property})
              if has_changed?(value, old_value)
                @#{property} = ObservablePropertyProxy.new(value, self, '#{property}')
                property_changed('#{property}', value, old_value)
              end
            end
          class_eval
        end
        
        def prepare_options(options)
          options = default_options.merge(options)
          if options[:reset_value].nil? and not options[:initial_value].class.include?(ObservablePropertySupport)
            options[:reset_value] = options[:initial_value]
          end
          options
        end
        
        def default_options
          { :core => false,
            :initial_value => nil,
            :reset_value => nil }
        end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    private
      def initialize_observers_if_needed
        @observers = [] if not defined?(@observers) or @observers.nil?
        @named_observers = {} if not defined?(@named_observers) or @named_observers.nil?
      end
    
      def get_old_value(property)
        begin
          return property.clone
        rescue TypeError
          return property
        end
      end

      def has_changed?(new_value, old_value)
        !(new_value.kind_of?(old_value.class) && old_value == new_value)
      end
      
      def clone_if_possible(value)
        value.clone
      rescue TypeError
        value
      end
  end
end
