module InitializeHooksHelper
  def before_initialize_called?
    @before_initialize_called == true
  end

  def after_initialize_called?
    @after_initialize_called == true
  end

  protected
    def before_initialize
      @before_initialize_called = true
    end

    def after_initialize
      @after_initialize_called = true
    end
end
