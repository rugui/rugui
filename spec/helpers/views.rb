# Defines some views used in specs.

require File.join(File.expand_path(File.dirname(__FILE__)), 'initialize_hooks_helper')

class MyView < RuGUI::BaseView
  include InitializeHooksHelper

  use_builder
  builder_file File.join(File.dirname(__FILE__), '..', 'resource_files', 'my_view.glade')
  root :top_window
  
  attr_accessor :message
  
  def setup_view_helpers
    register_helper :my_view_helper, :my_other_view_helper_instance
  end
  
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
  
  def property_my_other_view_helper_instance_message_changed(observable, new_value, old_value)
    @message = "Property message of my_other_view_helper_instance changed from #{old_value} to #{new_value}"
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
  use_builder
  builder_file File.join(File.dirname(__FILE__), '..', 'resource_files', 'my_other_view.glade')
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

class NoBuilderView < RuGUI::BaseView
end

class ConventionallyNamedView < RuGUI::BaseView
end

class NewStyleView < RuGUI::BaseView
end