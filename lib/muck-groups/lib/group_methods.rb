module MuckGroups
  module GroupMethods

    protected

      def get_group
        @group = Group.find_by_url_key(params[:group_id]) || Group.find(params[:group_id]) || Group.find(params[:id])
        if !@group
          flash[:notice] = "There was a problem finding the requested group information.  Please try again."
          permission_denied 
        end
      end

      def membership_required

        return true if is_admin?

        if !@group.can_participate?(current_user)
          flash[:notice] = "You have to be a member of the group to do that."
          permission_denied
          false
        end
      end

      # TODO decide if we need to keep this method or if we need to use authorized? from authenticated_system instead
      def authorization_required

        return true if is_admin?

        if !@group.can_edit?(current_user)
          flash[:notice] = "You don't have permission to do that."
          permission_denied
          @group = nil
          false
        end
      end

      def permission_denied      
        respond_to do |format|
          format.html do
            redirect_to group_path(@group)
          end
        end
      end

      def can_participate?
        @can_participate == true
      end
    
      def member?
        return false if @group.nil?
        user = @user || current_user
        @group.is_member?(user) || is_admin?
      end

      def manager?
        return false if @group.nil?
        user = @user || current_user
        @group.can_edit?(user)
      end
    
  end
end