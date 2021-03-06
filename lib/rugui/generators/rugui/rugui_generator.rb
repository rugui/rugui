class Rugui < Thor::Group
  include Thor::Actions

  argument :name
  argument :app_path, :optional => true,
           :desc => "The path where to generate the application, if not specified it will create the application in a directory with the same name of the application in the current directory."

  class_option :framework_adapter, :type => :string, :aliases => '-a', :default => 'gtk',
                :desc => "Choose which framework adapter to use, must be one of 'gtk', 'qt' or 'rubygame'"

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
    template 'Gemfile.tt'
  end

  def create_directory_structure
    directory_structure = [
      'bin',
      'app',
      'app/controllers',
      'app/models',
      'app/resources',
      'app/views',
      'app/views/view_helpers',
      'config',
      'config/environments',
      'lib',
      'lib/tasks',
      'log',
      'vendor'
    ]

    directory_structure.each do |directory|
      empty_directory directory
    end
  end

  def create_bin_files
    inside 'bin' do
      copy_file 'main_executable', "#{name}"
      chmod "#{name}", 0755
    end
  end

  def create_app_files
    inside 'app' do
      copy_file 'main.rb'
      directory 'controllers'
      directory 'views'
    end
  end

  def create_config_files
    directory 'config'
  end

  def create_framework_specific_files
    directory framework_specific_file('app/controllers'), 'app/controllers'
    directory framework_specific_file('app/views'), 'app/views'
    directory framework_specific_file('app/resources'), 'app/resources'
  end

  def create_test_files
    directory 'spec'
  end

  protected
    def framework_adapter_name
      case options[:framework_adapter]
      when 'gtk'
        'GTK'
      when 'qt'
        'Qt4'
      when 'rubygame'
        'Rubygame'
      end
    end

  private
    def framework_specific_file(path)
      File.join('framework_specific', options[:framework_adapter], path)
    end
end
