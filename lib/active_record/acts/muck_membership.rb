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
          feed_to = group.feed_to
          feed_to = (feed_to | user.feed_to) if group.visibility > Group::INVISIBLE
          feed_item = FeedItem.create(:item => self, :creator_id => self.user_id)
          feed_to.each{ |u| u.feed_items << feed_item }
        end

        def after_destroy
          feed_item = FeedItem.create(:item => group, :template => 'left_group', :creator_id => user_id)
          (group.feed_to).each{ |u| u.feed_items << feed_item }
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
