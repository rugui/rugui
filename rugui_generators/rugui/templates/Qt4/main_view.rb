class MainView < ApplicationView
  use_builder

  def setup_widgets
    connect(self.hello_button, 'clicked()', :on_hello_button_clicked)
  end

  # Add your stuff here.

  def on_hello_button_clicked
    puts "Hello button clicked."
    self.message_label.text = "You clicked me!"
  end
end
