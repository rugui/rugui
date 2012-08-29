module HelperManager
  class << self
    def clear!
      RuGUI::BaseObject.descendants.each do |klass|
        klass.clear_all_registries if klass.respond_to?(:clear_all_registries)
      end
    end
  end
end