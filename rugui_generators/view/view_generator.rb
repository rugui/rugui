require File.join(File.dirname(__FILE__), "../generators_support")

class ViewGenerator < RubiGen::Base
  include GeneratorsSupport

  default_options :author => nil

  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    @uses_glade = true
    super
    usage if args.empty?
    @name = args.shift
    extract_options
  end

  def manifest
    record do |m|
      build_view_templates(m)
    end
  end

  protected
    def banner
      <<-EOS
Creates a RuGUI view with its resources.

USAGE: script/generate view YOUR_VIEW_NAME [options]
EOS
    end

    def add_options!(opts)
      view_add_options!(opts)
    end
end
