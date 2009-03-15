class ModelGenerator < RubiGen::Base

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
      m.template "model.erb", "app/models/#{@name.underscore}.rb", :assigns => { :model_name => @name.camelize }
    end
  end

  protected
    def banner
      <<-EOS
Creates a RuGUI model.

USAGE: script/generate model YOUR_MODEL_NAME
EOS
    end

    def add_options!(opts)
      opts.separator ' '
    end

    def extract_options
    end
end
