#include MuckGroups::Models::MuckGroup
module MuckGroups
  module Models
    module MuckGroup
      
      extend ActiveSupport::Concern
      
      included do
      
        include ::AASM
        
        acts_as_taggable_on :tags
        
        validates_presence_of :creator, :name, :description
        validates_uniqueness_of :name

        has_many :uploads, :as => :uploadable, :order => 'created_at desc', :dependent => :destroy

        # TODO figure out if we want to keep these relationships
#          has_many :events, :as => :eventable, :order => 'created_at desc'
#          has_many :comments, :as => :commentable, :order => 'created_at desc'
#          has_many :photos, :as => :photoable, :order => 'created_at desc'
#          has_many :shared_entries, :as => :destination, :order => 'created_at desc', :include => :entry
#          has_many :public_google_docs, :through => :shared_entries, :source => 'entry', :conditions => 'google_doc = true AND public = true', :select => "*"
#          has_many :shared_uploads, :as => :shared_uploadable, :order => 'created_at desc', :include => :upload
#          has_many :pages, :as => :contentable, :class_name => 'ContentPage', :order => 'created_at desc'

        # membership and users
        has_many :membership_requests
        has_many :pledges, :through => :membership_requests, 
                          :dependent => :destroy, 
                          :source => :user

        belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'   

        has_many :memberships, :dependent => :destroy
        has_many :members, :through => :memberships, 
                          :dependent => :destroy,
                          :order => 'last_name, first_name',
                          :conditions => 'banned != true',
                          :select => 'users.*, memberships.role',
                          :source => :user do
                            def in_role(role, options = {})
                              find :all, { :conditions => ['role = ?' , role.to_s], :order => "memberships.created_at" }.merge(options)
                            end
                          end

        if MuckGroups.configuration.enable_solr
          require 'acts_as_solr'
          acts_as_solr({ :fields => [ :content_p => 'string', :content_u => 'string', :content_a => 'string', :visibility => 'integer' ] }, { :multi_core => true, :default_core => 'en' })
        end
        
        if MuckGroups.configuration.enable_sunspot
          require 'sunspot'
          searchable do
            text :content_p
            text :content_u 
            text :content_a
            integer :visibility
          end
        end

        include ::MuckActivities::Models::MuckActivityConsumer if MuckGroups.configuration.enable_group_activities
        
        has_attached_file :photo, 
                          :styles => { :big => "600x600",
                                       :medium => "300x300>",
                                       :thumb => "100x100>",
                                       :icon => "50x50>",
                                       :tiny => "24x24>" },
                          :default_url => "/images/group_default.jpg"

        scope :visible, where("visibility > 0")
        scope :by_name, order("name ASC")

        aasm_initial_state :approved
        
        # state information
        aasm_state :approved, :after => :notify_approve 
        aasm_state :banned, :after => :notify_ban

        aasm_event :approve do 
          transitions :to => :approved, :from => :banned
        end

        aasm_event :ban do 
          transitions :to => :banned, :from => :approved 
        end
        
      end
      
      def create_feed_item template = nil
        feed_item = FeedItem.create(:item => self, :creator_id => self.creator_id, :template => template)
        (self.creator.feed_to).each{ |u| u.feed_items << feed_item }
      end

      def create_forum
        @forum = self.forums.build(:name => self.name,
          :description => I18n.translate('muck.groups.forum_for_group', :forum => self.name))
        @forum.save
      end

      def feed_to
        [self] + self.members
      end

      def content_p
        visibility > MuckGroups::INVISIBLE ? "#{name} #{description} #{tags.collect{|t| t.name}.join(' ')}" : ''
      end

      def content_u
        content_p
      end

      def content_a
        "#{name} #{description} #{tags.collect{|t| t.name}.join(' ')}"
      end

      def default_role= val
        write_attribute(:default_role, val.to_s)
      end

      def default_role
        read_attribute(:default_role).to_sym
      end

      def is_content_visible? user
        return true if self.visibility > MuckGroups::PRIVATE
        return false if user == :false || user.nil?
        user.admin? || self.is_member?(user)
      end

      def notify_approve
      end

      def notify_ban
      end

      def is_member?(user)
        return false if user.nil?
        members.include?(user)
      end

      def is_pending_member?(user)
        return false if user.nil?
        pledges.include?(user)
      end

      def can_edit?(user)
        return false if user.nil?
        check_creator(user) || members.in_role(:manager).include?(user)
      end

      def can_upload?(check_user)
        is_member?(check_user)
      end

      def can_participate?(user)
        return false if user == :false
        user.has_role?('administrator') || !members.find(:all, :conditions => "user_id = #{user.id} AND role != 'banned' AND role != 'observer'").empty?
      end

      def remove_member(user)
        membership = memberships.find_by_user_id(user.id)
        membership.destroy
      end

      def remove_pledge(user)
        pledge = membership_requests.find_by_user_id(user.id)
        pledge.destroy if !pledge.nil?
      end

      # actually deleting a group could cause some problems so 
      # we cheat and just say we delete it
      def delete!
        update_attributes(:visibility => MuckGroups::DELETED)
      end

      def to_xml(options = {})
        options[:only] ||= []
        options[:only] << :name << :description << :icon << :state << :url_key << :created_at
        options[:only] << :default_role << :visibility << :requires_approval_to_join
        super
      end
      
    end

  end
end