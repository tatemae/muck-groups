#include MuckGroups::Models::MuckMembershipRequest
module MuckGroups
  module Models
    module MuckMembershipRequest
      
      extend ActiveSupport::Concern
      
      included do
        belongs_to :user
        belongs_to :group
      end

      def decline(decliner)
        return false if !group.can_edit?(decliner)
        destroy
        return true
      end
      
    end
  end
end