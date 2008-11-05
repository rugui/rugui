require 'rubygems'
require 'spec/rake/spectask'

RUGUI_ROOT = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')

task :stats => "spec:statsetup"

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{RUGUI_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Print Specdoc for all specs"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  # Setup specs for stats
  task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(RuGUI\ specs) if File.exist?('spec')
    ::CodeStatistics::TEST_TYPES << "RuGUI specs" if File.exist?('spec')
  end
end
