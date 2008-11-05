require 'fileutils'

module RuGUI
  module Generator
    class Application
      def run(options = {})
        parse_options(options)
        get_application_name_and_path_from_argv
        check_valid_application_name_and_path
        
        display_generate_app_init_message
        
        create_directory_structure
        generate_default_files_from_templates
        
        display_generate_app_finish_message
      end
      
      private
        def parse_options(options)
          @use_spec = options[:use_spec]
        end
      
        def get_application_name_and_path_from_argv
          @application_name = nil
          @application_path = nil
          
          ARGV.each do |arg|
            unless arg[0] == '-'[0]
              if @application_name.nil?
                @application_name = arg
              else
                @application_path = arg
              end
            end
          end
          
          @application_path ||= Dir.pwd
        end
        
        def check_valid_application_name_and_path
          raise RuGUI::Generator::Exceptions::ApplicationNameMustBeGiven.new('The application name must be given.') if @application_name.nil?
          raise RuGUI::Generator::Exceptions::ApplicationPathMustBeValid.new('The application path must be valid.') if @application_path.nil? or not File.exist?(@application_path)
        end
        
        def create_directory_structure
          FileUtils.mkdir(application_root_path)
          
          directory_structure = RuGUI::Generator::Configuration.default_application_directory_structure
          directory_structure.concat(RuGUI::Generator::Configuration.default_test_directory_structure)
          directory_structure.concat(RuGUI::Generator::Configuration.default_spec_directory_structure) if @use_spec
          directory_structure.each do |dir|
            FileUtils.mkdir(File.join(application_root_path, dir))
          end
        end
        
        def generate_default_files_from_templates
          templates_path = RuGUI::Generator::Configuration.templates_path
          files_mapping = RuGUI::Generator::Configuration.default_files_mapping
          files_mapping.concat(RuGUI::Generator::Configuration.default_test_files_mapping)
          files_mapping.concat(RuGUI::Generator::Configuration.default_spec_files_mapping) if @use_spec
          files_mapping.each do |file_mapping|
            source_file = File.join(templates_path, file_mapping[:filename])
            destination_file = File.join(application_root_path, file_mapping[:destination], file_mapping[:filename])
            FileUtils.copy_file(source_file, destination_file)
            FileUtils.chmod(file_mapping[:mode], destination_file)
          end
        end
        
        def display_generate_app_init_message
          puts "Generating application #{@application_name} on #{File.expand_path(@application_path)}"
          puts "Using RSpec for generated application" if @use_spec
          puts "Using TestUnit for generated application" unless @use_spec
        end
        
        def display_generate_app_finish_message
          puts "Application #{@application_name} generated in #{File.expand_path(@application_path)}"
        end
        
        def application_root_path
          File.join(File.expand_path(@application_path), @application_name)
        end
    end
  end
end
