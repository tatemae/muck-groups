require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipRequest do
  
  it { should belong_to :user }
  it { should belong_to :group }
  
end