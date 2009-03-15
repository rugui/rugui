module RuGUI
  module FrameworkAdapters
    module BaseFrameworkAdapter
      # Adapts the BaseController methods specific for the framework.
      class BaseController
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
        end
      end

      # Adapts the BaseMainController methods specific for the framework.
      class BaseMainController < RuGUI::FrameworkAdapters::BaseFrameworkAdapter::BaseController
        # Runs the application, starting anything the framework needs.
        def run
        end

        # Exits the application, freeing any resources used by the framework.
        def quit
        end
      end

      # Adapts the BaseModel methods specific for the framework
      class BaseModel
      end

      # Adapts the BaseView methods specific for the framework
      class BaseView
        
      end

      # Adapts the BaseViewHelper methods specific for the framework
      class BaseViewHelper
        # Queues the block call, so that it is only gets executed in the main thread.
        def queue(&block)
        end
      end
    end
  end
end
