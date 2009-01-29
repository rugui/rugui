# Defines some view helpers used in specs.

require File.join(File.expand_path(File.dirname(__FILE__)), 'initialize_hooks_helper')

class MyViewHelper < RuGUI::BaseViewHelper
  include InitializeHooksHelper
  
  observable_property :message, :initial_value => "Some label in the middle"
end
