module ActiveRecord
  module Acts #:nodoc:
    module MuckMembershipRequest #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def acts_as_muck_membership_request(options = {})
          
          belongs_to :user
          belongs_to :group
          
          include ActiveRecord::Acts::MuckMembershipRequest::InstanceMethods
          extend ActiveRecord::Acts::MuckMembershipRequest::SingletonMethods

        end
      end

      # class methods
      module SingletonMethods
  
      end

      # All the methods available to a record that has had <tt>acts_as_muck_membership_request</tt> specified.
      module InstanceMethods
        
        def decline(decliner)
          return false if !group.can_edit?(decliner)
          destroy
          return true
        end
        
      end

    end
  end
end
