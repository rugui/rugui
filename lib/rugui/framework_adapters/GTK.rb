require 'gtk2'

module Gtk
  GTK_PENDING_BLOCKS = []
  GTK_PENDING_BLOCKS_LOCK = Monitor.new

  def Gtk.queue(&block)
    if Thread.current == Thread.main
      block.call
    else
      GTK_PENDING_BLOCKS_LOCK.synchronize do
        GTK_PENDING_BLOCKS << block
      end
    end
  end

  # Adds a timeout to execute pending blocks in a queue.
  def Gtk.queue_timeout(timeout)
    Gtk.timeout_add timeout do
      GTK_PENDING_BLOCKS_LOCK.synchronize do
        GTK_PENDING_BLOCKS.each do |block|
          block.call
        end
        GTK_PENDING_BLOCKS.clear
      end
      true
    end
  end
end

module RuGUI
  module FrameworkAdapters
    module GTK
      class BaseController
        def queue(&block)
          Gtk.queue(&block)
        end
      end

      class BaseMainController < RuGUI::FrameworkAdapters::GTK::BaseController
        def run
          Gtk.queue_timeout(RuGUI.configuration.queue_timeout)
          Gtk.main
        end

        def quit
          Gtk.main_quit
        end
      end
    end
  end
end