require File.dirname(__FILE__) + '/../spec_helper'

describe Group do

  describe "A group instance" do

    before do
      @group = Factory(:group)
      @manager = Factory(:user)
      Factory(:membership, :user => @manager, :group => @group, :role => 'manager')
      @member = Factory(:user)
      Factory(:membership, :user => @member, :group => @group)
      @user = Factory(:user)
    end

    it { should scope_by_name }

    it { should belong_to :creator }
    it { should have_many :membership_requests }
    #it { should have_many :members, :through => :memberships, :source => :user }

    # TODO the next version of shoulda should handle the :source param.  Uncomment these lines when it does
#    it { should have_many :comments }
#    it { should have_many :events }
#    it { should have_many :pages    #should_have_many :photos, :class_name => 'GroupPhoto' }
#    it { should have_many :shared_uploads }
#    it { should have_many :uploads }

    it { should validate_presence_of :description }
    it { should validate_presence_of :creator }
    
    it { should validate_uniqueness_of :name }

    it "should create a new group" do
      lambda{
        group = Factory(:group)
        group.should be_new_record
        group.aasm_state.should == :approved        
      }.should change(Group, :count)
    end

    it "should add a 'manager' role for the group creator" do
      lambda{
        group = Factory(:group)
        group.members.in_role(:manager).should include(group.creator)        
      }.should change(Group, :count)
    end

    it "should create a new group and set default role" do
      lambda{
        group = Factory(:group, :default_role => 'dude')
        group.should_not be_new_record
        group.aasm_state.should == :approved
        group.default_role.should == :dude        
      }.should change(Group, :count)
    end

    it "should get members in the 'member' role" do
      members = @group.members.in_role(:member, :limit => 10)
      members.length.should > 0
    end

    it "should get members in the 'manager' role" do
      members = @group.members.in_role(:manager, :limit => 10)
      members.length.should > 0
    end

    it "should get a list of other users to share activity feed with" do
      share_with = @group.feed_to
      share_with.should include(@member)
      share_with.should include(@manager)
    end

    it "should be taggable" do
      group = Factory(:group)
      group.should_not be_new_record
      group.tag_list = "ruby, rails, muck"
      group.save!.should be_true
      Group.tagged_with("muck", :on => :tags).should include(group)
    end

    it "should ban a group" do
      group = Factory(:group)
      group.ban!
      group.reload
      group.banned?.should be_true
    end

    it "should delete a group" do
      group = Factory(:group)
      group.delete!
      group.reload
      group.visibility.should == Group::DELETED
    end

    describe "manager" do
      it "should be able to edit" do
        @group.can_edit?(@manager).should be_true
      end
    end

    describe "member" do
      it "should not be able to edit" do
        @group.can_edit?(@member).should be_false
      end
    end

    describe "user" do
      it "should not be able to edit" do
        @group.can_edit?(@user).should be_false
      end
    end

  end

  describe "public group" do
    before do
      @user = Factory(:user)
      @group = Factory(:group, :visibility => MuckGroups::PUBLIC)
    end

    it "should be visible to invalid user" do
      @group.is_content_visib.should be_e(false)
    end
  
    it "should be visible to nil user" do
      @group.is_content_visib.should be_e(nil)
    end
  
    it "should be visible to valid user" do
      @group.is_content_visib.should be_e(@user)
    end
  end
  
  describe "invisible group" do
    before do
      @invisible_group = Factory(:group, :visibility => MuckGroups::INVISIBLE)
      @member = Factory(:user)
      Factory(:membership, :user => @member, :group => @invisible_group)
    end

    it "should be invisible but visible to a member" do
      @invisible_group.is_content_visib.should be_e(@member)
    end

    it "should not be visible to nil user" do
      @invisible_group.is_content_visib.should_not be_e(nil)
    end
      
    it "should not be visible to invalid user" do
      @invisible_group.is_content_visib.should_not be_e(false)
    end
    
  end
  
end
