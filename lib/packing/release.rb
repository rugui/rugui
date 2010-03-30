begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rugui"
    gemspec.summary = "A simple MVC framework for RubyGTK."
    gemspec.email = ["vicente.mundim@gmail.com", "fmesquitacunha@gmail.com", "claudioe@gmail.com", "thecatwasnot@gmail.com"]
    gemspec.homepage = "http://rugui.org"
    gemspec.description = "A simple MVC framework for RubyGTK."
    gemspec.authors = ["Vicente Mundim", "Felipe Mesquita", "Claudio Escudero", "Cole Teeter"]
    gemspec.add_dependency(%q<activesupport>, [">= 2.1.1"])
    gemspec.add_dependency(%q<thor>, [">= 0.13.3"])
    gemspec.date = %q{2010-03-30}
    gemspec.rubyforge_project = "rugui"
    gemspec.executables = ['rugui']
    gemspec.files = FileList["bin/*", "lib/**/*", "script/*", "Changelog", "LICENSE", "Rakefile", "README"].to_a
    gemspec.test_files = FileList["spec/**/*"].to_a
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
