$VERBOSE = nil

# Load RuGUI framework rakefile extensions
Dir["#{File.dirname(__FILE__)}/*_framework.rake"].each { |ext| load ext }
