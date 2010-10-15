#include MuckGroups::Models::MuckMembership
module MuckGroups
  module Models
    module MuckMembership
      
      extend ActiveSupport::Concern
      
      included do
        belongs_to :user
        belongs_to :group, :counter_cache => 'member_count'

        include ::MuckActivities::Models::MuckActivitySource if MuckGroups.configuration.enable_group_activities
      end

      def after_create
        if MuckGroups.configuration.enable_group_activities && group.visibility > MuckGroups::INVISIBLE
          content = I18n.t('muck.groups.joined_status', :name => self.user.display_name, :group => self.group.name)
          add_activity(group.feed_to, self, self, 'joined_group', '', content)
        end
      end

      def after_destroy
        if MuckGroups.configuration.enable_group_activities && group.visibility > MuckGroups::INVISIBLE
          content = I18n.t('muck.groups.left_status', :name => self.user.display_name, :group => self.group.name)
          add_activity(group.feed_to, self, self, 'left_group', '', content)
        end
      end

      # roles can be defined as symbols.  We want to store them as strings in the database
      def role= val
        write_attribute(:role, val.to_s)
      end

      def role
        read_attribute(:role).to_sym
      end
      
    end

  end
end