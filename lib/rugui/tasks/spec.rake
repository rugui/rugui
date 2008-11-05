require 'rubygems'
require 'spec/rake/spectask'

task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{APPLICATION_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{APPLICATION_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("#{APPLICATION_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end

  desc "Print Specdoc for all specs (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  desc "Print Specdoc for all plugin specs"
  Spec::Rake::SpecTask.new(:plugin_doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*')
  end

  [:models, :controllers, :views, :view_helpers, :lib].each do |sub|
    desc "Run the specs under spec/#{sub}"
    Spec::Rake::SpecTask.new(sub) do |t|
      t.spec_opts = ['--options', "\"#{APPLICATION_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    end
  end

  desc "Run the specs under vendor/plugins (except RSpec's own)"
  Spec::Rake::SpecTask.new(:plugins) do |t|
    t.spec_opts = ['--options', "\"#{APPLICATION_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*').exclude("vendor/plugins/rspec-rails/*")
  end

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
