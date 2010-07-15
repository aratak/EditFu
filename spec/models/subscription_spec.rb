require 'spec_helper'

describe Subscription do

  should_belong_to :owner
  should_validate_presence_of :starts_at, :ends_at, :price

end



# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  owner_id   :integer(4)
#  starts_at  :datetime
#  ends_at    :datetime
#  price      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer(4)
#

