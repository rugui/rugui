# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rugui}
  s.version = "1.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vicente Mundim", "Felipe Mesquita", "Claudio Escudero"]
  s.date = %q{2009-08-04}
  s.default_executable = %q{rugui}
  s.description = %q{A simple MVC framework for RubyGTK.}
  s.email = ["vicente.mundim@gmail.com", "fmesquitacunha@gmail.com", "claudioe@gmail.com"]
  s.executables = ["rugui"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README",
     "README.rdoc"
  ]
  s.files = [
    "Changelog",
     "LICENSE",
     "README",
     "Rakefile",
     "bin/rugui",
     "lib/packing/release.rb",
     "lib/rugui.rb",
     "lib/rugui/base_controller.rb",
     "lib/rugui/base_model.rb",
     "lib/rugui/base_object.rb",
     "lib/rugui/base_view.rb",
     "lib/rugui/base_view_helper.rb",
     "lib/rugui/configuration.rb",
     "lib/rugui/entity_registration_support.rb",
     "lib/rugui/framework_adapters/GTK.rb",
     "lib/rugui/framework_adapters/Qt4.rb",
     "lib/rugui/framework_adapters/base_framework_adapter.rb",
     "lib/rugui/framework_adapters/framework_adapter_support.rb",
     "lib/rugui/gem_builder.rb",
     "lib/rugui/gem_dependency.rb",
     "lib/rugui/initialize_hooks.rb",
     "lib/rugui/initializer.rb",
     "lib/rugui/log_support.rb",
     "lib/rugui/observable_property_proxy.rb",
     "lib/rugui/observable_property_support.rb",
     "lib/rugui/plugin/loader.rb",
     "lib/rugui/property_changed_support.rb",
     "lib/rugui/property_observer.rb",
     "lib/rugui/signal_support.rb",
     "lib/rugui/tasks/gems_application.rake",
     "lib/rugui/tasks/release_framework.rake",
     "lib/rugui/tasks/rugui.rb",
     "lib/rugui/tasks/rugui_framework.rb",
     "lib/rugui/tasks/runner_application.rake",
     "lib/rugui/tasks/spec_application.rake",
     "lib/rugui/tasks/spec_framework.rake",
     "lib/rugui/tasks/test_application.rake",
     "lib/rugui/vendor_gem_source_index.rb",
     "lib/rugui/version.rb",
     "rugui_generators/controller/USAGE",
     "rugui_generators/controller/controller_generator.rb",
     "rugui_generators/controller/templates/controller.erb",
     "rugui_generators/generators_support.rb",
     "rugui_generators/model/USAGE",
     "rugui_generators/model/model_generator.rb",
     "rugui_generators/model/templates/model.erb",
     "rugui_generators/pack/USAGE",
     "rugui_generators/pack/pack_generator.rb",
     "rugui_generators/pack/templates/README",
     "rugui_generators/rugui/USAGE",
     "rugui_generators/rugui/rugui_generator.rb",
     "rugui_generators/rugui/templates/GTK/application_controller.rb",
     "rugui_generators/rugui/templates/GTK/application_view.rb",
     "rugui_generators/rugui/templates/GTK/application_view_helper.rb",
     "rugui_generators/rugui/templates/GTK/environment.rb",
     "rugui_generators/rugui/templates/GTK/main.rc",
     "rugui_generators/rugui/templates/GTK/main_controller.rb",
     "rugui_generators/rugui/templates/GTK/main_view.glade",
     "rugui_generators/rugui/templates/GTK/main_view.rb",
     "rugui_generators/rugui/templates/GTK/main_view_helper.rb",
     "rugui_generators/rugui/templates/Qt4/application_controller.rb",
     "rugui_generators/rugui/templates/Qt4/application_view.rb",
     "rugui_generators/rugui/templates/Qt4/application_view_helper.rb",
     "rugui_generators/rugui/templates/Qt4/environment.rb",
     "rugui_generators/rugui/templates/Qt4/main_controller.rb",
     "rugui_generators/rugui/templates/Qt4/main_view.rb",
     "rugui_generators/rugui/templates/Qt4/main_view.ui",
     "rugui_generators/rugui/templates/Qt4/main_view_helper.rb",
     "rugui_generators/rugui/templates/README",
     "rugui_generators/rugui/templates/Rakefile",
     "rugui_generators/rugui/templates/boot.rb",
     "rugui_generators/rugui/templates/development.rb.sample",
     "rugui_generators/rugui/templates/main.rb",
     "rugui_generators/rugui/templates/main_executable.bat.erb",
     "rugui_generators/rugui/templates/main_executable.erb",
     "rugui_generators/rugui/templates/production.rb.sample",
     "rugui_generators/rugui/templates/rcov.opts",
     "rugui_generators/rugui/templates/spec.opts",
     "rugui_generators/rugui/templates/spec_helper.rb",
     "rugui_generators/rugui/templates/test.rb.sample",
     "rugui_generators/rugui/templates/test_helper.rb",
     "rugui_generators/view/USAGE",
     "rugui_generators/view/templates/toplevels/about_dialog.glade",
     "rugui_generators/view/templates/toplevels/assistant.glade",
     "rugui_generators/view/templates/toplevels/color_selection_dialog.glade",
     "rugui_generators/view/templates/toplevels/dialog_box.glade",
     "rugui_generators/view/templates/toplevels/file_chooser_dialog.glade",
     "rugui_generators/view/templates/toplevels/font_selection_dialog.glade",
     "rugui_generators/view/templates/toplevels/input_dialog.glade",
     "rugui_generators/view/templates/toplevels/message_dialog.glade",
     "rugui_generators/view/templates/toplevels/recent_chooser_dialog.glade",
     "rugui_generators/view/templates/toplevels/window.glade",
     "rugui_generators/view/templates/view.erb",
     "rugui_generators/view/templates/view.glade",
     "rugui_generators/view/templates/view.ui",
     "rugui_generators/view/templates/view_helper.erb",
     "rugui_generators/view/view_generator.rb",
     "script/console",
     "script/destroy",
     "script/generate",
     "spec/framework/base_controller_spec.rb",
     "spec/framework/base_model_spec.rb",
     "spec/framework/base_view_helper_spec.rb",
     "spec/framework/base_view_spec.rb",
     "spec/framework/log_support_spec.rb",
     "spec/framework/observable_property_proxy_spec.rb",
     "spec/framework/observable_property_support_spec.rb",
     "spec/framework/property_observer_spec.rb",
     "spec/helpers/controllers.rb",
     "spec/helpers/initialize_hooks_helper.rb",
     "spec/helpers/models.rb",
     "spec/helpers/observables.rb",
     "spec/helpers/view_helpers.rb",
     "spec/helpers/views.rb",
     "spec/rcov.opts",
     "spec/resource_files/my_other_view.glade",
     "spec/resource_files/my_view.glade",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://rugui.org}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rugui}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple MVC framework for RubyGTK.}
  s.test_files = [
    "spec/framework/base_model_spec.rb",
     "spec/framework/property_observer_spec.rb",
     "spec/framework/observable_property_proxy_spec.rb",
     "spec/framework/observable_property_support_spec.rb",
     "spec/framework/base_view_spec.rb",
     "spec/framework/base_view_helper_spec.rb",
     "spec/framework/log_support_spec.rb",
     "spec/framework/base_controller_spec.rb",
     "spec/spec_helper.rb",
     "spec/helpers/initialize_hooks_helper.rb",
     "spec/helpers/models.rb",
     "spec/helpers/view_helpers.rb",
     "spec/helpers/observables.rb",
     "spec/helpers/controllers.rb",
     "spec/helpers/views.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.1.1"])
      s.add_runtime_dependency(%q<rubigen>, [">= 1.5.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.1.1"])
      s.add_dependency(%q<rubigen>, [">= 1.5.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.1.1"])
    s.add_dependency(%q<rubigen>, [">= 1.5.1"])
  end
end
