require 'test_helper'

class MyView < RuGUI::BaseView
end

class MyModel < RuGUI::BaseModel
end

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

class TestBaseController < Test::Unit::TestCase
  def setup
    @controller = MyController.new
  end
  
  def test_that_registered_views_can_be_retrieved_as_attributes_or_using_views_hash
    assert_instance_of MyView, @controller.views[:my_view]
    assert_instance_of MyView, @controller.my_view
    assert_equal @controller.views[:my_view], @controller.my_view
  end
  
  def test_that_registered_models_can_be_retrieved_as_attributes_or_using_models_hash
    assert_instance_of MyModel, @controller.models[:my_model]
    assert_instance_of MyModel, @controller.my_model
    assert_equal @controller.models[:my_model], @controller.my_model
  end
  
  def test_that_registered_controllers_can_be_retrieved_as_attributes_or_using_controllers_hash
    assert_instance_of MyChildController, @controller.controllers[:my_child_controller]
    assert_instance_of MyChildController, @controller.my_child_controller
    assert_equal @controller.controllers[:my_child_controller], @controller.my_child_controller
  end
end