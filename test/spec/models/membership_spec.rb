require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  
  it { should belong_to :user }
  it { should belong_to :group }
  
end