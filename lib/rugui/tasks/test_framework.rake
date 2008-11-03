desc 'Run all tests'
task :test do
  errors = %w(test:test).collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors}!" if errors.any?
end

namespace :test do

  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.pattern = 'test/test_*.rb'
    t.verbose = true
  end
  Rake::Task['test'].comment = "Run the tests in test"

end