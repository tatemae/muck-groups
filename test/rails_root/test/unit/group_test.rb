require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase

  context 'A group instance' do

    setup do
      @group = Factory(:group)
      @manager = Factory(:user)
      Factory(:membership, :user => @manager, :group => @group, :role => 'manager')
      @member = Factory(:user)
      Factory(:membership, :user => @member, :group => @group)
      @user = Factory(:user)
    end

    should_belong_to :creator
    should_have_many :membership_requests        
    #should_have_many :members, :through => :memberships, :source => :user

    # TODO the next version of shoulda should handle the :source param.  Uncomment these lines when it does
#    should_have_many :comments
#    should_have_many :events
#    should_have_many :pages    #should_have_many :photos, :class_name => 'GroupPhoto'
#    should_have_many :shared_uploads
#    should_have_many :uploads

    should_validate_presence_of :description
    should_validate_presence_of :creator
    
    should_validate_uniqueness_of :name

    should "Create a new group" do
      assert_difference 'Group.count' do
        group = Factory(:group)
        assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
        assert group.aasm_state == :approved
      end
    end

    should "add a 'manager' role for the group creator" do
      assert_difference 'Group.count' do
        group = Factory(:group)
        assert group.members.in_role(:manager).include?(group.creator)
      end
    end

    should "Create a new group and set default role" do
      assert_difference 'Group.count' do
        group = Factory(:group, :default_role => 'dude')
        assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
        assert group.aasm_state == :approved
        assert group.default_role == :dude
      end
    end

    should "get members in the 'member' role" do
      members = @group.members.in_role(:member, :limit => 10)
      assert members.length > 0
    end

    should "get members in the 'manager' role" do
      members = @group.members.in_role(:manager, :limit => 10)
      assert members.length > 0
    end

    should "get a list of other users to share activity feed with" do
      share_with = @group.feed_to
      assert share_with.include?(@member)
      assert share_with.include?(@manager)
    end

    should "be taggable" do
      group = Factory(:group)
      assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
      group.tag_list = "ruby, rails, muck"
      assert group.save!
      assert Group.tagged_with("muck", :on => :tags).include?(group)
    end

    should "ban a group" do
      group = Factory(:group)
      group.ban!
      group.reload
      assert group.banned?
    end

    should "delete a group" do
      group = Factory(:group)
      group.delete!
      group.reload
      assert group.visibility == Group::DELETED
    end

    context "manager" do
      should "be able to edit" do
        assert @group.can_edit?(@manager)
      end
    end

    context "member" do
      should "not be able to edit" do
        assert !@group.can_edit?(@member)
      end
    end

    context "user" do
      should "not be able to edit" do
        assert !@group.can_edit?(@user)
      end
    end

  end

  context "public group" do
    setup do
      @user = Factory(:user)
      @group = Factory(:group, :visibility => MuckGroups::PUBLIC)
    end

    should "be visible to invalid user" do
      assert @group.is_content_visible?(false)
    end
  
    should "be visible to nil user" do
      assert @group.is_content_visible?(nil)
    end
  
    should "be visible to valid user" do
      assert @group.is_content_visible?(@user)
    end
  end
  
  context 'invisible group' do
    setup do
      @invisible_group = Factory(:group, :visibility => MuckGroups::INVISIBLE)
      @member = Factory(:user)
      Factory(:membership, :user => @member, :group => @invisible_group)
    end

    should "be invisible but visible to a member" do
      assert @invisible_group.is_content_visible?(@member)
    end

    should "not be visible to nil user" do
      assert !@invisible_group.is_content_visible?(nil)
    end
      
    should "not be visible to invalid user" do
      assert !@invisible_group.is_content_visible?(false)
    end
    
  end
  
end
