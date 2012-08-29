begin
  require 'rspec/core/rake_task'

  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec)

  task :stats => "spec:statsetup"
  task :default => :spec

  namespace :spec do
    # Setup specs for stats
    task :statsetup do
      require 'code_statistics'
      ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
      ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
      ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
      ::STATS_DIRECTORIES << %w(ViewHelper\ specs spec/helpers) if File.exist?('spec/view_helpers')
      ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
      ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
      ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
      ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
      ::CodeStatistics::TEST_TYPES << "ViewHelper specs" if File.exist?('spec/view_helpers')
      ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
      ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
    end
  end
rescue LoadError
  # RSpec gem or rubygems are not installed, in order to use RSpec related tasks
  # they should be installed.
end