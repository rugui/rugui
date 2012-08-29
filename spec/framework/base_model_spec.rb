require 'spec_helper'

describe RuGUI::BaseModel do
  describe "with initialization hooks" do
    it "should call before initialize and after initialize methods" do
      model = MyModel.new
      model.before_initialize_called?.should be_true
      model.after_initialize_called?.should be_true
    end
  end
end
