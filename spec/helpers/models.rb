# Defines some models used in specs.

require File.join(File.expand_path(File.dirname(__FILE__)), 'initialize_hooks_helper')

class MyModel < RuGUI::BaseModel
  include InitializeHooksHelper
  
  observable_property :my_property
end
