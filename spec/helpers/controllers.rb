# Defines some controllers used in specs.

class MyController < RuGUI::BaseController
  def setup_views
    register_view :my_view
  end
  
  def setup_models
    register_model :my_model
  end
  
  def setup_controllers
    register_controller :my_child_controller
  end
end

class MyChildController < RuGUI::BaseController
end