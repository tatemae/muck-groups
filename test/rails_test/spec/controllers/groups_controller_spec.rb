require File.dirname(__FILE__) + '/../spec_helper'

describe Muck::GroupsController do
  
  describe "groups controller" do
    before do
      @group      = Factory(:group)
      @africa     = Factory(:group)
      @invisible  = Factory(:group)
    end

    it { should require_login :new, :get }
    it { should require_login :edit, :get }
    it { should require_login :create, :post }
    it { should require_login :update, :put }
    it { should require_login :destroy, :delete }
    
    describe "not logged in" do

      describe "view normal group" do
        before do
          get :show, :id => groups(:africa).to_param
        end
        it { should respond_with :success }
        it { should render_template :show }
      end
    
      describe "view invisible group" do
        before do
          get :show, :id => groups(:invisible).to_param
        end
        it { should redirect_to groups_path }
      end

      describe "view private group" do
        before do
          get :show, :id => groups(:private).to_param
        end
        it { should respond_with :success }
        it { should render_template :show }
        it "should show group information" do
          assert_select "#information", :count => 1
        end
        it "should not show group officers" do
          assert_select "#group-officers", :count => 0
        end
      end

      describe "get index page" do
        before do
          get :index
        end
        it "should not show invisible groups" do
          # check the page to make sure the invisible group isn't there
          # assert_select ".invisible", :count => 0
        end
      end
    end

    describe "logged in, not a member" do

      before do
        login_as users(:aaron)
        @group = groups(:invisible)
      end

      should_deny_group_admin_actions(:africa)
      should_deny_group_admin_actions(:invisible)

      describe "view invisible group" do
        before do
          get :show, :id => @group.to_param
        end
        it { should redirect_to groups_path }
      end
    end

    describe "logged in member - not manager or admin" do

      before do
        login_as users(:africa_member)
        @group = groups(:africa)
      end        

      should_deny_group_admin_actions(:africa)
      should_deny_group_admin_actions(:invisible)

      describe "view invisible group" do
        before do
          login_as users(:invisible_member)
          get :show, :id => groups(:invisible).to_param
        end
        it { should respond_with :success }
        it { should render_template :show }
      end

    end

    describe "logged in manager" do

      before do
        @admin_user = users(:admin)
        login_as @admin_user
      end        

      should_be_restful do |resource|
        resource.actions    = [:index, :show, :edit, :update]
        resource.formats    = [:html]
        resource.create.params = { :name => "a random new group", :description => 'this is the random group', :default_role => 'member'}
        resource.update.params = { :name => "Changed", :description => 'this is the changed, random group' }    
      end

      describe "show the group" do
        before do
          get :show, :id => groups(:africa).to_param
        end

        it { should respond_with :success }
        it { should render_template :show }

        it "should have a join link since admin isn't a member" do
          assert_select "div#join_group"
          assert_select "a", :text => "Join #{groups(:africa).name}"
        end

      end

      describe "update group" do
        before do
          @new_group_name = 'new group name asdf'
          @new_description = 'new group description'
          put :update, :id => @group.to_param, :group => { :name => @new_group_name, :description => @new_description }
        end

        it { should redirect_to group_path(@group) }
        it { should set_the_flash.to(/Group was successfully updated/i) }

        it "should have new values" do
          @group.reload
          @group.name.should == @new_group_name
          @group.description.should == @new_description
        end

      end        

      describe "DELETE to destroy" do
        before do
          @group = Factory(:group, :creator => @admin_user)
        end
      
        it "should delete a group" do
          lambda{
            delete :destroy, { :id => @group.to_param }
            should redirect_to groups_url            
          }.should change(Group, :count).by(-1)
        end
      end
    
    end

  end
  
end

def should_deny_group_admin_actions(name)

  describe "deny access to admin actions" do

    before do
      @group_to_test = self.instance_variable_get("@#{name.to_s}")
    end

    it "should now allow edit" do
      get :edit, :id => @group_to_test.to_param
      should redirect_to group_url(@group_to_test)
      ensure_flash(PERMISSION_DENIED_MSG)
    end

    it "should not allow update" do
      put :update, :id => @group_to_test.to_param
      should redirect_to group_url(@group_to_test)
      ensure_flash(PERMISSION_DENIED_MSG)
    end

    it "should not allow destroy" do
      delete :destroy, :id => @group_to_test.to_param
      should redirect_to group_url(@group_to_test)
      ensure_flash(PERMISSION_DENIED_MSG)
    end

  end

end
