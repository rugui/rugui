class ControllerGenerator < RubiGen::Base

  default_options :author => nil

  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    extract_options
  end

  def manifest
    record do |m|
      m.template "controller.erb", "app/controllers/#{@name.downcase}_controller.rb", :assigns => { :controller_name => @name.capitalize }
    end
  end

  protected
    def banner
      <<-EOS
Creates a RuGUI controller.

USAGE: script/generate controller YOUR_CONTROLLER_NAME
EOS
    end

    def add_options!(opts)
      opts.separator ' '
    end

    def extract_options
    end
end
