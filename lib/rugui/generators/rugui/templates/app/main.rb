#! /usr/bin/ruby

#
# You can run this application by running this file.
# Do not modify it, unless you know what you are doing.
#

require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

main_controller = MainController.new
main_controller.run
