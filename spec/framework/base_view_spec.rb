require 'spec_helper'

describe RuGUI::BaseView do
  before(:each) do
    @my_view = MyView.new
    @my_child_view = MyChildView.new
    @my_other_view = MyOtherView.new
    @my_other_view_instance = MyOtherView.new
  end

  describe "with view widget registering" do
    it "should make widgets available as attributes in the view class instance" do
      @my_view.top_window.should be_an_instance_of(Gtk::Window)
      @my_view.vertical_container.should be_an_instance_of(Gtk::VBox)
      @my_view.button_above.should be_an_instance_of(Gtk::Button)
      @my_view.button_below.should be_an_instance_of(Gtk::Button)
      @my_view.label.should be_an_instance_of(Gtk::Label)
    end
  end

  describe "with builder file accessor" do
    it "should return different value for different view classes" do
      @my_view.builder_file.should_not == @my_other_view.builder_file
    end

    it "should return the same value for same view classes" do
      @my_other_view.builder_file.should == @my_other_view_instance.builder_file
    end

    it "should return the same value for subclasses which don't override it" do
      @my_view.builder_file.should == @my_child_view.builder_file
    end
  end

  describe "when creating a view without builder file" do
    it "should not raise error" do
      lambda {
        @no_builder_view_instance = NoBuilderView.new
      }.should_not raise_error(RuGUI::BuilderFileNotFoundError)
    end
  end

  describe "when including a child view into a parent view" do
    it "should include the root widget of the child view into the specified widget in the parent view" do
      @my_view.include_view :vertical_container, @my_child_view
      @my_view.vertical_container.children.include?(@my_child_view.root_widget).should  be_true
    end
  end

  describe "whent removing a child view from a parent view" do
    before do
      @my_view.include_view :vertical_container, @my_child_view
    end

    it "should remove the root widget of the child view from the specified widget in the parent view" do
      @my_view.remove_view :vertical_container, @my_child_view
      @my_view.vertical_container.children.include?(@my_child_view.root_widget).should_not  be_true
    end
  end

  describe "with view helpers" do
    it "should include a default view helper automatically if it exists" do
      @my_view.respond_to?(:helper).should be_true
      @my_view.helper.should be_an_instance_of(MyViewHelper)
    end

    it "should not include a default view helper automatically if it does not exists" do
      @my_other_view.respond_to?(:helper).should be_false
    end

    it "should notify the view when an observable property is changed in the view helper" do
      @my_view.helper.message = "another message"
      @my_view.message.should == "MyViewHelper property message changed from Some label in the middle to another message"
    end

    it "should be notified using named observable property change calls" do
      @my_view.my_other_view_helper_instance.message = "foo"
      @my_view.message.should == "Property message of my_other_view_helper_instance changed from Some label in the middle to foo"
    end
  end

  describe "with initialization hooks" do
    it "should call before initialize and after initialize methods" do
      view = MyView.new
      view.before_initialize_called?.should be_true
      view.after_initialize_called?.should be_true
    end
  end
end
