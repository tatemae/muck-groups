require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsMailer do

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  it "should send invite email" do
    inviter = Factory(:user)
    email = 'asdf@example.com'
    name = 'asdf'
    subject = "Invitation"
    message = "Come join our group"
    email = GroupsMailer.invite(inviter, group, email, name, subject, message).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.to.should == [email]
    email.from.should == [MuckEngine.configuration.from_email]
  end
  
end 