module RuGUI
  module EntityRegistrationSupport
    module ClassMethods
      def register(entity, *names)
        names.each do |name|
          register_entity entity, name
        end
      end

      private
        def register_entity(entity, name)
          self.entity_registrations[entity] ||= []
          self.entity_registrations[entity] << name
        end
    end

    def self.included(base)
      base.class_inheritable_accessor :entity_registrations
      base.entity_registrations = {}
      base.extend(ClassMethods)
    end

    protected
      def register_all(entity)
        if self.entity_registrations.has_key?(entity)
          self.entity_registrations[entity].each do |name|
            register(entity, name)
          end
        end
      end

      def register(entity, object_or_name, name = nil)
        name = register_name_for(object_or_name, name)
        if should_register?(name)
          object = create_or_get_instance_for(entity, object_or_name)
          setup_instance(entity, name, object)
          call_after_register_for(entity, object, name)
          object
        end
      end

    private
      def register_name_for(object_or_name, name)
        if object_or_name.is_a?(String) or object_or_name.is_a?(Symbol)
          name || object_or_name.to_s.underscore
        else
          name || object_or_name.class.to_s.underscore
        end
      end

      def should_register?(name)
        not respond_to?(name) or send(name).nil?
      end

      def create_or_get_instance_for(entity, object_or_name)
        if object_or_name.is_a?(String) or object_or_name.is_a?(Symbol)
          args = create_instance_arguments_for(entity) || []
          get_instance_for(entity, object_or_name) or create_instance(object_or_name, *args)
        else
          object_or_name
        end
      end

      def create_instance_arguments_for(entity)
        send("create_instance_arguments_for_#{entity}") if respond_to?("create_instance_arguments_for_#{entity}", true)
      end

      def get_instance_for(entity, name)
        send("get_instance_for_#{entity}", name) if respond_to?("get_instance_for_#{entity}", true)
      end

      def create_instance(klass_name, *args)
        klass_name.to_s.camelize.constantize.new(*args)
      end

      def setup_instance(entity, name, object)
        send("#{entity}s")[name.to_sym] = object
        create_attribute_reader(entity, name)
      end

      def call_after_register_for(entity, object, name)
        send("after_register_#{entity}", object, name) if respond_to?("after_register_#{entity}", true)
      end

      # Creates an attribute reader for the some entity.
      def create_attribute_reader(type, name)
        self.class.class_eval <<-class_eval
          def #{name}
            @#{type}s[:#{name}]
          end
        class_eval
      end
  end
end