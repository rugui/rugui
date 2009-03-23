module GeneratorsSupport
  protected
    # Build controller templates.
    def build_controller_templates(m)
      m.template "../../controller/templates/controller.erb", "app/controllers/#{@name.underscore}_controller.rb", :assigns => { :controller_name => @name.camelize }
    end

    # Build view templates.
    def build_view_templates(m)
      # app/views
      m.template "../../view/templates/view.erb", "app/views/#{@name.underscore}_view.rb", :assigns => { :view_name => @name.camelize, :uses_builder => uses_builder? }
      # app/views/helpers
      m.template "../../view/templates/view_helper.erb", "app/views/helpers/#{@name.underscore}_view_helper.rb", :assigns => { :view_name => @name.camelize }
      if uses_builder?
        if framework_based_on_directory_structure == 'GTK'
          # app/resources/glade
          m.file glade_template, "app/resources/glade/#{@name.underscore}_view.glade"
        else
          # app/resources/ui
          m.file ui_template, "app/resources/ui/#{@name.underscore}_view.ui"
        end
      end
    end

    # Implements add_options!(opts) for views.
    def view_add_options!(opts)
      opts.separator ' '
      opts.on("-x", "--without-builder", "Create the view without a glade.") { |o| @uses_builder = false }
      opts.on("-e", "--default-builder", "Create the view with a default builder.") { |o| @toplevel = nil }
      opts.on("-w", "--window", option_phrase_for('window')) { |o| @toplevel = "window" }
      opts.on("-d", "--dialog-box", option_phrase_for('dialog box')) { |o| @toplevel = "dialog_box" }
      opts.on("-a", "--about-dialog", option_phrase_for('about dialog')) { |o| @toplevel = "about_dialog" }
      opts.on("-u", "--color-selection-dialog", option_phrase_for('color selection dialog')) { |o| @toplevel = "color_selection_dialog" }
      opts.on("-j", "--file-chooser-dialog", option_phrase_for('file chooser dialog')) { |o| @toplevel = "file_chooser_dialog" }
      opts.on("-n", "--font-selection-dialog", option_phrase_for('font selection dialog')) { |o| @toplevel = "font_selection_dialog" }
      opts.on("-i", "--input-dialog", option_phrase_for('input dialog')) { |o| @toplevel = "input_dialog" }
      opts.on("-m", "--message-dialog", option_phrase_for('message dialog')) { |o| @toplevel = "message_dialog" }
      opts.on("-r", "--recent-chooser-dialog", option_phrase_for('recent chooser dialog')) { |o| @toplevel = "recent_chooser_dialog" }
    end

    # Implements add_options!(opts) for controllers.
    def controller_add_options!(opts)
      opts.separator ' '
    end

    def option_phrase_for(toplevel)
      "Create the view with a glade file using #{toplevel} template as toplevel (GTK only)."
    end

    # Gets the correct glade template.
    def glade_template
      return "../../view/templates/view.glade" if @toplevel.nil?
      return "../../view/templates/toplevels/#{@toplevel}.glade"
    end

    # Gets the correct glade template.
    def ui_template
      return "../../view/templates/view.ui"
    end

    def uses_builder?
      !!@uses_builder
    end

    def extract_options
    end

    def framework_based_on_directory_structure
      if File.exist?("app/resources/ui")
        'Qt4'
      else
        'GTK'
      end
    end
end
