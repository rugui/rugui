class MainView < ApplicationView
  use_glade

  # Add your stuff here.

  def on_hello_button_clicked(widget)
    puts "Hello button clicked."
    self.message_label.text = "You clicked me!"
  end
end
