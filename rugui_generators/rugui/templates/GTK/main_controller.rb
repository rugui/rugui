# The main controller for the application.
#
# NOTE: This controller doesn't inherit from ApplicationController, instead, it
# inherits from RuGUI::BaseMainController. Use it only as a starting point.
# Commonly it is used only to register global models and controllers, as well as
# the main view, but this is entirely up to you.
class MainController < RuGUI::BaseMainController
  # Add your stuff here.

  def setup_views
    register_view :main_view
  end

  def on_main_window_delete_event(widget, event)
    quit
  end
end
