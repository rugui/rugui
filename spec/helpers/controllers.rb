# Defines some controllers used in specs.

class MyController < RuGUI::BaseController
  attr_accessor :message
  
  def setup_views
    register_view :my_view
  end
  
  def setup_models
    register_model :my_model
    register_model :my_model, :my_other_model_instance
  end
  
  def setup_controllers
    register_controller :my_child_controller
  end
  
  def property_my_other_model_instance_my_property_changed(model, new_value, old_value)
    @message = "Property my_property of named observable my_other_model_instance changed from #{old_value} to #{new_value}."
  end
end

class MyChildController < RuGUI::BaseController
end