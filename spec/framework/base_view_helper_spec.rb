require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'helpers', 'view_helpers')

describe RuGUI::BaseViewHelper do
  describe "with initialization hooks" do
    it "should call before initialize and after initialize methods" do
      view_helper = MyViewHelper.new
      view_helper.before_initialize_called?.should be_true
      view_helper.after_initialize_called?.should be_true
    end
  end
end
