class RuguiGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])


  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    set_initial_values
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      # Root files
      m.file_copy_each %w(README Rakefile)
      # app/
      m.file "main.rb", "app/main.rb"
      # app/controllers
      %w(main application).each do |file|
        m.file "#{file}_controller.rb", "app/controllers/#{file}_controller.rb"
      end
      # app/views
      %w(main application).each do |file|
        m.file "#{file}_view.rb", "app/views/#{file}_view.rb"
      end
      # app/view/helpers
      %w(main application).each do |file|
        m.file "#{file}_view_helper.rb", "app/views/helpers/#{file}_view_helper.rb"
      end
      # app/resources/glade
      m.file "main_view.glade", "app/resources/glade/main_view.glade"
      # app/resources/styles
      m.file "main.rc", "app/resources/styles/main.rc"

      # config/
      %w(boot environment).each { |file| m.file "#{file}.rb", "config/#{file}.rb" }
      # config/environments
      %w(development test production).each do |file|
        m.file "#{file}.rb.sample", "config/environments/#{file}.rb.sample"
      end

      # test/
      if @test_suite.include?("unit")
        TEST_DIRS.each { |path| m.directory path }
        m.file "test_helper.rb", "test/test_helper.rb"
      end

      # spec/
      if @test_suite.include?("rspec")
        RSPEC_DIRS.each { |path| m.directory path }
        %w(rcov.opts spec.opts spec_helper.rb).each { |file| m.file file, "spec/#{file}"  }
      end

      # scripts/
      m.dependency "install_rubigen_scripts", [destination_root, 'rugui'],
        :shebang => options[:shebang], :collision => :force
    end
  end

  protected
    def banner
<<-EOS
Creates a RuGUI application.

USAGE: #{spec.name} YOUR_PROJECT_NAME
EOS
    end

    def add_options!(opts)
      opts.separator ' '
      opts.separator 'Options:'
      opts.on("-r", "--rspec", "Add RSpec support to the project.") { |o| @test_suite << "rspec"  }
      opts.on("-o", "--only-rspec", "Use RSpec instead of Test::Unit::TestCase.") { |o| @test_suite = ["rspec"]  }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    # Set initial values.
    def set_initial_values
      @test_suite = ["unit"]
    end

    def extract_options
    end

    BASEDIRS = [
      # bin directory contains executables for the application.
      'bin',
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
      # vendor directory contains third-party software.
      'vendor'
    ]

    TEST_DIRS = [
      'test',
      'test/controllers',
      'test/models',
      'test/views',
      'test/views/helpers',
      'test/lib'
    ]

    RSPEC_DIRS = [
      'spec',
      'spec/controllers',
      'spec/models',
      'spec/views',
      'spec/views/helpers',
      'spec/lib'
    ]
end
