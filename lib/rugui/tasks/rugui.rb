$VERBOSE = nil

# Load RuGUI rakefile extensions
Dir["#{File.dirname(__FILE__)}/*_application.rake"].each { |ext| load ext }

# Load any custom rakefile extensions
Dir["#{APPLICATION_ROOT}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }
Dir["#{APPLICATION_ROOT}/vendor/plugins/*/**/tasks/**/*.rake"].sort.each { |ext| load ext }
