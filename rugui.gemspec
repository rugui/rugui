# -*- encoding: utf-8 -*-

require File.expand_path(File.join('lib', 'rugui', 'version'))

Gem::Specification.new do |s|
  s.name = %q{rugui}
  s.version = RuGUI::VERSION
  s.summary = %q{A rails like MVC framework for building desktop applications with GUI frameworks.}
  s.description = %q(
    RuGUI is a framework which aims to help building desktop applications.
    RuGUI was mostly inspired by the *Ruby on Rails* framework, taking most of its features from it.
    It provides adapters for GTK and Qt ruby bindings, and you can build other adapters if you wish.
  )

  s.authors = ["Vicente Mundim", "Felipe Mesquita", "Claudio Escudero", "Cole Teeter", "Sebastien Nicouleaud"]
  s.email = ["vicente.mundim@gmail.com", "fmesquitacunha@gmail.com", "claudioe@gmail.com", "thecatwasnot@gmail.com", "sebastien.nicouleaud@gmail.com"]
  s.homepage = %q{http://rugui.org}
  s.rubyforge_project = %q{rugui}
  s.licenses = ["GNU LGPL"]

  s.executables = %w(rugui)

  s.extra_rdoc_files = %w(LICENSE README.rdoc)
  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.rdoc Rakefile Changelog Thorfile)
  s.test_files = Dir.glob("spec/**/*")

  s.rdoc_options = %w(--charset=UTF-8 --main=README.rdoc)

  s.required_rubygems_version = ">= 1.4.0"

  s.add_runtime_dependency(%q<rake>, [">= 0.9.2.2"])
  s.add_runtime_dependency(%q<activesupport>, [">= 3.2.0"])
  s.add_runtime_dependency(%q<thor>, [">= 0.14.6"])
  s.add_runtime_dependency(%q<gtk2>, [">= 1.1.5"])

  s.add_development_dependency(%q<rspec>, [">= 2.11.0"])
end

