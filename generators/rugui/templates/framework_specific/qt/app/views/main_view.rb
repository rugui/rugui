class MainView < ApplicationView
  use_builder

  # Add your stuff here.

  on :hello_button, 'clicked()' do
    puts "Hello button clicked."
    self.message_label.text = "You clicked me!"
  end
end
