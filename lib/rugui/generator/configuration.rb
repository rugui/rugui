module RuGUI
  module Generator
    class Configuration
      def self.default_application_directory_structure
        [
          # app directory contains the controllers, models, resources, and views.
          'app',
          'app/controllers',
          'app/models',
          'app/resources',
          'app/resources/glade',
          'app/resources/styles',
          'app/views',
          'app/views/helpers',

          # config directory contains environments configuration, boot file and
          # other configuration stuff.
          'config',
          'config/environments',

          # lib directory contains utility libraries which doesn't fit into a
          # separate gem or plugin. Also it contains additional rake tasks which
          # will be automatically added if present in lib/tasks.
          'lib',
          'lib/tasks',

          # log directory contains default log files for the application.
          'log',

          # test directory contains tests for controllers, models, and libs. Test
          # files should be named as <test_class>_test.rb in order to be
          # automatically recognized.
          'test',
          'test/controllers',
          'test/libs',
          'test/models',

          # vendor directory contains third-party software.
          'vendor',
        ]
      end
      
      def self.templates_path
        File.join(File.expand_path(File.dirname(__FILE__)), 'generator_templates')
      end
      
      def self.default_files_mapping
        [
          file_mapping('app', 'main.rb', 0700),
          file_mapping('app/controllers', 'main_controller.rb'),
          file_mapping('app/controllers', 'application_controller.rb'),
          file_mapping('app/resources/glade', 'main_view.glade'),
          file_mapping('app/resources/styles', 'main.rc'),
          file_mapping('app/views', 'application_view.rb'),
          file_mapping('app/views', 'main_view.rb'),
          file_mapping('app/views/helpers', 'application_view_helper.rb'),
          file_mapping('app/views/helpers', 'main_view_helper.rb'),
          file_mapping('config', 'boot.rb'),
          file_mapping('config', 'environment.rb'),
          file_mapping('config/environments', 'development.rb.sample'),
          file_mapping('config/environments', 'test.rb.sample'),
          file_mapping('config/environments', 'production.rb.sample'),
          file_mapping('test', 'test_helper.rb'),
          file_mapping('', 'README'),
          file_mapping('', 'Rakefile'),
        ]
      end
      
      private
        def self.file_mapping(destination, filename, mode = 0666)
          { :destination => destination, :filename => filename, :mode => mode }
        end
    end
  end
end
