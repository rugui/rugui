require 'rubygame'

Rubygame::TTF.setup if defined?(Rubygame::TTF)

module RuGUI
  module FrameworkAdapters
    module Rubygame
      class BaseController < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseController
        def queue(&block)
          block.call
        end
      end

      class BaseMainController < RuGUI::FrameworkAdapters::Rubygame::BaseController
        def run
          catch :quit do
            loop do
              self.adapted_object.step
            end
          end
        end

        def refresh
        end

        def quit
          throw :quit
          Rubygame.quit
        end
      end

      class BaseView < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseView
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
          block.call
        end

        # Connects the signal from the widget to the given receiver block.
        # The block is executed in the context of the receiver.
        def connect_declared_signal_block(widget, signal, receiver, block)
        end

        # Connects the signal from the widget to the given receiver method.
        def connect_declared_signal(widget, signal, receiver, method)
        end

        # Builds widgets from the given filename, using the proper builder.
        def build_widgets_from(filename)
        end

        # Registers widgets as attributes of the view class.
        def register_widgets
        end

        class << self
          # Returns the builder file extension to be used for this view class.
          def builder_file_extension
          end
        end
      end
    end
  end
end

module RuGUI
  class BaseController < BaseObject
    include Rubygame::EventHandler::HasEventHandler
  end

  class BaseMainController < BaseController
    attr_accessor :screen

    def initialize
      super

      setup_clock
      setup_event_queue
      setup_screen
      setup_quit_events
      setup_main_view_screen
    end

    def step
      clear_screen
      tick
      handle_events
      update
      screen.update
    end

    def tick
      event_queue << clock.tick
    end

    def clock
      @clock ||= Rubygame::Clock.new
    end

    def event_queue
      @event_queue ||= Rubygame::EventQueue.new
    end

    class << self
      def ignored_events(*args)
        @ignored_events ||= []
        @ignored_events += args unless args.empty?
        @ignored_events
      end

      def framerate(frames_per_second=nil)
        @framerate ||= frames_per_second || 30
      end

      def screen_width(width=nil)
        @screen_width ||= width || 640
      end

      def screen_height(height=nil)
        @screen_height ||= height || 480
      end

      def screen_depth(depth=nil)
        @screen_depth ||= depth || 0
      end

      def screen_flags(flags=nil)
        @screen_flags ||= flags || [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
      end

      def screen_title(title=nil)
        @screen_title ||= title || "RuGUI Game!"
      end

      def quit_hooks(quit_hooks=nil)
        @quit_hooks ||= quit_hooks || [:escape, :q, Rubygame::Events::QuitRequested]
      end
    end

    protected
      # Your MainController can overwrite this and implement different clear screen logic.
      def clear_screen
        screen.fill :black
      end

      # Your MainController should overwrite this and implement update logic.
      def update
      end

    private
      def setup_clock
        clock.target_framerate = self.class.framerate
        clock.calibrate
        clock.enable_tick_events
      end

      def setup_event_queue
        event_queue.enable_new_style_events
        event_queue.ignore = self.class.ignored_events
      end

      def setup_screen
        self.screen = Rubygame::Screen.new(
          [self.class.screen_width, self.class.screen_height],
          self.class.screen_depth,
          self.class.screen_flags)

        self.screen.title = self.class.screen_title
      end

      def setup_quit_events
        hooks = self.class.quit_hooks.inject({}) { |accumulator, hook| accumulator.merge(hook => :quit) }
        make_magic_hooks hooks
      end

      def setup_main_view_screen
        main_view.screen = screen if respond_to?(:main_view) && main_view.respond_to?(:screen=)
      end

      def handle_events
        event_queue.each do |event|
          handle event
        end
      end
  end
end

module Rubygame
  module Sprites
    module Sprite
      # Makes it call super
      def initialize
        super

        @groups = []
        @depth = 0
      end
    end
  end
end