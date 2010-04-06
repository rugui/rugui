class MainView < ApplicationView
  attr_accessor :screen

  def update_screen
    screen.fill :black

    # update screen logic goes here
  end
end
