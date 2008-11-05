require File.expand_path(File.dirname(__FILE__) + '/configuration')
require File.expand_path(File.dirname(__FILE__) + '/exceptions')
require File.expand_path(File.dirname(__FILE__) + '/application')

module RuGUI
  module Generator
    class Base
      def initialize
        @generators = {
          :app => RuGUI::Generator::Application,
          # put more generators here.
        }
      end
      
      def self.generate(generator, options = {})
        self.new.run(generator, options)
      rescue Exception => exception
        print_exception_trace(exception)
      end
      
      def run(generator, options = {})
        @generators[generator].new.run(options)
      end
      
      private
        def self.print_exception_trace(exception)
          if ARGV.include?('--verbose') or ARGV.include?('-vv')
            puts "#{exception}\n#{exception.backtrace.join("\n")}"
          else
            puts exception
          end
        end
    end
  end
end
