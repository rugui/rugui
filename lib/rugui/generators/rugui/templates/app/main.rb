#! /usr/bin/ruby

#
# You can run this application by running this file.
# Do not modify it, unless you know what you are doing.
#

require File.expand_path('../../config/environment', __FILE__)

main_controller = MainController.new
main_controller.run
