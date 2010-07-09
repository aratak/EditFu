require 'spec_helper'

describe Subscription do

  should_belong_to :owner
  
  

end

# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  owner_id   :integer(4)
#  start_at   :date
#  end_at     :date
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

