begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rugui"
    gemspec.summary = "A simple MVC framework for RubyGTK."
    gemspec.email = ["vicente.mundim@intelitiva.com", "felipe.mesquita@intelitiva.com", "claudio.escudero@intelitiva.com"]
    gemspec.homepage = "http://rugui.org"
    gemspec.description = "A simple MVC framework for RubyGTK."
    gemspec.authors = ["Vicente Mundim", "Felipe Mesquita", "Claudio Escudero"]
    gemspec.add_dependency(%q<activesupport>, [">= 2.1.1"])
    gemspec.add_dependency(%q<rubigen>, [">= 1.5.1"])
    gemspec.version = "1.3.0"
    gemspec.date = %q{2009-04-01}
    gemspec.rubyforge_project = "rugui"
    gemspec.executables = ['rugui']
    gemspec.files = FileList["bin/*", "lib/**/*", "rugui_generators/**/*", "script/*", "spec/**/*", "Changelog", "LICENSE", "Rakefile", "README"].to_a
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
