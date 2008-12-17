require 'erb'
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
          files_mapping.each do |file_mapping|
            if use_erb_for_file?(file_mapping)
              copy_erb_parsed_file(file_mapping)
            else
              copy_file(file_mapping)
            end

            configure_file_mode(file_mapping)
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

        def files_mapping
          mapping = RuGUI::Generator::Configuration.default_files_mapping
          mapping.concat(RuGUI::Generator::Configuration.default_test_files_mapping)
          mapping.concat(RuGUI::Generator::Configuration.default_spec_files_mapping) if @use_spec
          mapping
        end

        def use_erb_for_file?(file_mapping)
          file_mapping[:filename] =~ /.erb/
        end

        def copy_erb_parsed_file(file_mapping)
          source_file = File.join(templates_path, file_mapping[:filename])
          erb = ERB.new(File.read(source_file))
          @application_root = application_root_path
          parsed_file = erb.result(binding)
          open(destination_filename(file_mapping), 'w') do |file|
            file.write(parsed_file)
          end
        end

        def copy_file(file_mapping)
          source_file = File.join(templates_path, file_mapping[:filename])
          FileUtils.copy_file(source_file, destination_filename(file_mapping))
        end

        def configure_file_mode(file_mapping)
          FileUtils.chmod(file_mapping[:mode], destination_filename(file_mapping))
        end

        def destination_filename(file_mapping)
          name = file_mapping[:use_app_name_instead_of_filename] ? @application_name : file_mapping[:filename]
          File.join(application_root_path, file_mapping[:destination], "#{name}#{file_mapping[:custom_extension]}")
        end
        
        def application_root_path
          File.join(File.expand_path(@application_path), @application_name)
        end

        def templates_path
          @templates_path ||= RuGUI::Generator::Configuration.templates_path
        end
    end
  end
end
