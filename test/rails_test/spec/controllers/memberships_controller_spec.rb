require File.dirname(__FILE__) + '/../../spec_helper'

describe Groups::MembershipsController do

  def setup
    @controller = Groups::MembershipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group      = Factory(:group)
    @membership = Factory(:membership, :group => @group)
  end

  def self.should_get_index
    describe "GET index page" do
      before do
        get :index, { :group_id => groups(:africa).to_param }
      end
      it { should respond_with :success }
      it { should render_template :index }
      it { should_not set_the_flash }
    end
  end

  def self.should_leave_group
    describe "DELETE to :destroy - leave group" do
      before do
        delete :destroy, { :group_id => groups(:africa).to_param }
      end

      it { should respond_with :success }
      should_render_template "groups/_join_controls"
    end
  end

  def self.should_join_group

    describe "POST to create - join group" do
      before do
        post :create, { :group_id => groups(:africa).to_param }
      end
      it { should redirect_to group_path(@group) }
      it { should set_the_flash.to(/You have joined the group/i) }
    end

    describe "POST to create - join group (js)" do
      before do
        post :create, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      it { should respond_with :success }
      should_render_template "groups/_member_controls"
      it { should_not set_the_flash }
    end

  end

  def self.should_not_rejoin_group

    describe "POST to create - join group" do
      before do
        post :create, { :group_id => groups(:africa).to_param }
      end
      it { should redirect_to group_path(@group) }
      it { should set_the_flash.to(/You are already a member of/i) }
    end

    describe "POST to create - join group (js)" do
      before do
        post :create, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      it { should respond_with :success }
      should_render_template "groups/_member_controls"
      it { should_not set_the_flash }
    end

  end

  describe "anonymous user" do

    should_get_index

    describe "attempts to join " do
      before do
        post :create, { :group_id => groups(:africa).to_param }
      end

      it { should set_the_flash.to(/You must be logged in to access this feature/i) }
      it { should redirect_to login_path }
    end

    describe "attempts to join (js)" do
      before do
        post :create, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      it { should_not set_the_flash }
      it { should respond_with 406 }
    end

    describe "attempts to leave " do
      before do
        delete :destroy, { :group_id => groups(:africa).to_param }
      end
      it { should set_the_flash.to(/You must be logged in to access this feature/i) }
      it { should redirect_to login_path }
    end

    describe "attempts to leave (js)" do
      before do
        delete :destroy, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      it { should_not set_the_flash }
      it { should respond_with 406 }
    end

    describe "attempt to join invisible group" do
      before do
        get :new, { :group_id => groups(:invisible).to_param }
      end
      it { should set_the_flash.to(/You must be logged in to access this feature/i) }
      it { should redirect_to login_path }
    end

  end

  describe "logged in as group member" do
    before do
      login_as :africa_member
    end

    should_get_index
    should_leave_group
    should_not_rejoin_group
  end

  describe "logged in as group creator" do
    before do
      login_as :quentin
    end

    should_get_index
    should_leave_group
    should_not_rejoin_group
  end

  describe "logged in as admin" do
    before do
      login_as :admin
    end

    should_get_index
    should_join_group
    should_leave_group
  end

  describe "logged in as non group member" do
    before do
      login_as :aaron
    end

    describe "attempt to join invisible group" do
      before do
        get :new, { :group_id => groups(:invisible).to_param }
      end

      it { should respond_with :success }
      should_render_template "new"
      it { should_not set_the_flash }

    end

    should_get_index
    should_join_group
    should_leave_group
  end

end
