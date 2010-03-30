class Rugui < Thor::Group
  include Thor::Actions

  argument :name, :default => 'test'
  argument :app_path, :optional => true,
           :desc => "The path where to generate the application, if not specified it will create the application in a directory with the same name of the application in the current directory."

  class_option :framework_adapter, :type => :string, :aliases => 'a', :default => 'gtk',
                :desc => "Choose which framework adapter to use, must either 'gtk' or 'qt'"

  class_option :test_framework, :type => :string, :aliases => 't', :default => 'RSpec',
                :desc => "Choose which test framework to use, defaults to 'RSpec', but can be set to 'test-unit' also"

  class_option :version, :type => :boolean, :aliases => "-v", :group => :rugui,
                           :desc => "Show RuGUI version number and quit"
 
  class_option :help, :type => :boolean, :aliases => "-h", :group => :rugui,
                      :desc => "Show this help message and quit"

  def self.source_root
    File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end

  def create_root
    self.destination_root = File.expand_path(app_path || name, destination_root)
    empty_directory '.'

    FileUtils.cd(destination_root)
  end

  def create_root_files
    copy_file 'README'
    copy_file 'Rakefile'
  end

  def create_bin_files
    empty_directory 'bin'
    
    inside 'bin' do
      copy_file 'main_executable', "#{name}"
      chmod "#{name}", 0755

      template 'main_executable.bat', "#{name}.bat"
      chmod "#{name}.bat", 0755
    end
  end

  def create_app_files
    empty_directory 'app'

    inside 'app' do
      copy_file 'main.rb'
    end
  end

  def create_config_files
    directory 'config'
  end

  def create_lib_files
    empty_directory 'lib'
  end

  def create_log_files
    empty_directory 'log'
  end

  def create_vendor_files
    empty_directory 'vendor'
  end

  def create_framework_specific_files
    directory framework_specific_file('app/controllers'), 'app/controllers'
    directory framework_specific_file('app/views'), 'app/views'
    directory framework_specific_file('app/resources'), 'app/resources'
  end

  def create_test_files
    directory test_framework_dir
  end

  private
    def framework_specific_file(path)
      File.join('framework_specific', options[:framework_adapter], path)
    end

    def test_framework_dir
      options[:test_framework] == 'RSpec' ? 'spec' : 'test'
    end
end
