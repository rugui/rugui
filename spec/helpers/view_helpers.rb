# Defines some view helpers used in specs.

class MyViewHelper < RuGUI::BaseViewHelper
  observable_property :message, :initial_value => "Some label in the middle"
end
