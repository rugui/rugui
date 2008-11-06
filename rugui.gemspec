require 'rake'

Gem::Specification.new do |spec|
  spec.name = %q{rugui}
  spec.version = "0.3.0"
  spec.date = %q{2008-11-04}
  spec.authors = %q{"Vicente Mundim", "Felipe Mesquita", "Claudio Escudero"}
  spec.email = %q{vicente.mundim@intelitiva.com felipe.mesquita@intelitiva.com claudio.escudero@intelitiva.com}
  spec.homepage = "http://rugui.org"
  spec.summary = %q{A simple MVC framework for RubyGTK.}
  spec.has_rdoc = true
  spec.description = %q{A simple MVC framework for RubyGTK.}
  spec.files = FileList['bin/*','lib/**/*', "README", "Changelog", "LICENSE"].to_a
  spec.executables = ['rugui']
  spec.test_files = Dir.glob('test/*.rb')
  spec.add_dependency(%q<activesupport>, ["= 2.1.1"])
  spec.rubyforge_project = 'rugui'
end
