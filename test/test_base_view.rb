require 'test_helper'
require 'rugui/base_view'

class MyViewHelper < RuGUI::BaseViewHelper
  observable_property :message, :initial_value => "Some label in the middle"
end

class MyView < RuGUI::BaseView
  use_glade
  builder_file File.join(File.dirname(__FILE__),'resource_files', 'my_view.glade')
  root :top_window
  
  attr_accessor :message
  
  def on_button_above_clicked(widget)
    @message = "#{self.class} button above clicked."
  end
  
  def on_button_below_clicked(widget)
    @message = "#{self.class} button below clicked."
  end
  
  def on_top_window_delete_event(widget, event)
    @message = "#{self.class} top window deleted."
  end
  
  def property_message_changed(observable, new_value, old_value)
    @message = "#{observable.class.name} property message changed from #{old_value} to #{new_value}"
  end
end

class MyChildView < MyView
  root :vertical_container
  
  def on_button_above_clicked(widget)
    @message = "#{self.class} button above clicked."
  end
  
  def on_button_below_clicked(widget)
    @message = "#{self.class} button below clicked."
  end
end

class MyOtherView < RuGUI::BaseView
  use_glade
  builder_file File.join(File.dirname(__FILE__),'resource_files', 'my_other_view.glade')
  root :top_window
  
  attr_accessor :message
  
  def on_button_right_clicked(widget)
    @message = "#{self.class} button right clicked."
  end
  
  def on_button_left_clicked(widget)
    @message = "#{self.class} button left clicked."
  end
  
  def on_top_window_delete_event(widget, event)
    @message = "#{self.class} top window deleted."
  end
end

class TestBaseView < Test::Unit::TestCase
  def setup
    @my_view = MyView.new
    @my_child_view = MyChildView.new
    @my_other_view = MyOtherView.new
    @my_other_view_instance = MyOtherView.new
  end
  
  def test_that_view_widgets_have_accessor_attributes
    assert_instance_of Gtk::Window, @my_view.top_window
    assert_instance_of Gtk::VBox, @my_view.vertical_container
    assert_instance_of Gtk::Button, @my_view.button_above
    assert_instance_of Gtk::Button, @my_view.button_below
    assert_instance_of Gtk::Label, @my_view.label
  end
  
  def test_that_builder_file_accessor_returns_a_different_value_for_different_view_classes
    assert_not_equal @my_view.builder_file, @my_other_view.builder_file
  end
  
  def test_that_builder_file_accessor_returns_the_same_value_for_identical_classes
    assert_equal @my_other_view.builder_file, @my_other_view_instance.builder_file
  end
  
  def test_that_builder_file_accessor_returns_the_same_value_for_subclasses
    assert_equal @my_view.builder_file, @my_child_view.builder_file
  end

  def test_that_my_child_view_can_be_included_in_my_view
    @my_view.include_view :vertical_container, @my_child_view
    included_view = @my_view.vertical_container.children.select do |child|
      child == @my_child_view.root_widget
    end
    assert !included_view.empty?
  end
  
  def test_that_default_view_helper_is_registered_autommatically_if_it_exists
    assert @my_view.respond_to?(:helper)
    assert_kind_of RuGUI::BaseViewHelper, @my_view.helper
  end
  
  def test_that_default_view_helper_is_not_registered_autommatically_if_it_dont_exists
    assert_equal false, @my_other_view.respond_to?(:helper)
  end
  
  def test_that_changing_a_property_in_the_view_helper_notifies_the_view
    @my_view.helper.message = "another message"
    assert_equal "MyViewHelper property message changed from Some label in the middle to another message", @my_view.message
  end
end