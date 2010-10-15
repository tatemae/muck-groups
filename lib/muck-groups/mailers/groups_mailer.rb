module MuckGroups
  module Mailers
    module GroupMailer

      extend ActiveSupport::Concern
  
      def invite(inviter, group, email, name, subject, message)
        @name = name
        @message = message
        @inviter = inviter
        @group = group
        mail(:to => email, :subject => subject) do |format|
          format.html
          format.text
        end
      end
  
    end
  end
end


