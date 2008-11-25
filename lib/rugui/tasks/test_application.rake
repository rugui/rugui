TEST_CHANGES_SINCE = Time.now - 600

# Look up tests for recently modified sources.
def recent_tests(source_pattern, test_path, touched_since = 10.minutes.ago)
  FileList[source_pattern].map do |path|
    if File.mtime(path) > touched_since
      tests = []
      source_dir = File.dirname(path).split("/")
      source_file = File.basename(path, '.rb')
      
      # Support subdirs in app/models and app/controllers
      modified_test_path = source_dir.length > 2 ? "#{test_path}/" << source_dir[1..source_dir.length].join('/') : test_path

      # For modified files in app/ run the tests for it. ex. /test/models/account_controller.rb
      test = "#{modified_test_path}/#{source_file}_test.rb"
      tests.push test if File.exist?(test)

      # For modified files in app, run tests in subdirs too. ex. /test/functional/account/*_test.rb
      test = "#{modified_test_path}/#{File.basename(path, '.rb').sub("_controller","")}"
      FileList["#{test}/*_test.rb"].each { |f| tests.push f } if File.exist?(test)
		
      return tests

    end
  end.flatten.compact
end

desc 'Run all models, controllers and libs tests'
task :test do
  errors = %w(test:models test:controllers test:libs).collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

namespace :test do

  Rake::TestTask.new(:recent) do |t|
    since = TEST_CHANGES_SINCE
    touched = FileList['test/**/*_test.rb'].select { |path| File.mtime(path) > since } +
      recent_tests('app/models/**/*.rb', 'test/models', since) +
      recent_tests('app/controllers/**/*.rb', 'test/controllers', since) + 
      recent_tests('lib/**/*.rb', 'test/libs', since)

    t.libs << 'test'
    t.verbose = true
    t.test_files = touched.uniq
  end
  Rake::Task['test:recent'].comment = "Test recent changes"
  
  Rake::TestTask.new(:models) do |t|
    t.libs << "test"
    t.pattern = 'test/models/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:models'].comment = "Run the models tests in test/models"

  Rake::TestTask.new(:controllers) do |t|
    t.libs << "test"
    t.pattern = 'test/controllers/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:controllers'].comment = "Run the controllers tests in test/unit"

  Rake::TestTask.new(:libs) do |t|
    t.libs << "test"
    t.pattern = 'test/lib/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:libs'].comment = "Run the libs tests in test/unit"

end