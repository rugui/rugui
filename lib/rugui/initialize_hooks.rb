module RuGUI
  # Adds before/after hooks for initialize method of a class.
  module InitializeHooks
    def self.included(base)
      self.update_initialize_method(base)
    end

    def self.update_initialize_method(base)
      base.class_eval <<-class_eval
        alias :original_initialize :initialize

        def initialize(*args)
          initialize_with_hooks(*args)
        end
      class_eval
    end

    # Calls the original initialize method with before/after hooks.
    def initialize_with_hooks(*args)
      before_initialize
      original_initialize(*args)
      after_initialize
    end

    protected
      # Called before the initialize method. Subclasses can reimplement this in
      # order to have custom behavior.
      def before_initialize
      end

      # Called after the initialize method. Subclasses can reimplement this in
      # order to have custom behavior.
      def after_initialize
      end
  end
end