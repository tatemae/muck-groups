module ActiveRecord
  module Acts #:nodoc:
    module MuckMembership #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def acts_as_muck_membership(options = {})

          belongs_to :user
          belongs_to :group, :counter_cache => 'member_count'

          acts_as_activity_source if GlobalConfig.enable_group_activities

          include ActiveRecord::Acts::MuckMembership::InstanceMethods
          extend ActiveRecord::Acts::MuckMembership::SingletonMethods

        end
      end

      # class methods
      module SingletonMethods
  
      end

      # All the methods available to a record that has had <tt>acts_as_muck_membership</tt> specified.
      module InstanceMethods
        
        def after_create
          if GlobalConfig.enable_group_activities && group.visibility > MuckGroups::INVISIBLE
            content = I18n.t('muck.groups.joined_status', :name => self.user.display_name, :group => self.group.name)
            add_activity(group.feed_to, self, self, 'joined_group', '', content)
          end
        end

        def after_destroy
          if GlobalConfig.enable_group_activities && group.visibility > MuckGroups::INVISIBLE
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
end
