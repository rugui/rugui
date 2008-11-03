require 'rake'

Gem::Specification.new do |spec|
  spec.name = %q{rugui}
  spec.version = "0.2.0"
  spec.date = %q{2008-11-03}
  spec.authors = ["Vicente Mundim", "Felipe Mesquita", "Claudio Escudero"]
  spec.email = %q{vicente.mundim@intelitiva.com felipe.mesquita@intelitiva.com claudio.escudero@intelitiva.com}
  spec.summary = %q{A simple MVC framework for RubyGTK.}
  spec.description = %q{A simple MVC framework for RubyGTK.}
  spec.files = FileList['lib/**/*.rb', "README", "Changelog", "LICENSE"].to_a
  spec.test_files = Dir.glob('test/test_*.rb') 
  spec.add_dependency(%q<activesupport>, ["= 2.1.1"])
end 
