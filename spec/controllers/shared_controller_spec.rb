require 'spec_helper'

describe SharedController do

  describe "GET 'trial_period'" do
    it "should be successful" do
      get 'trial_period'
      response.should be_success
    end
  end
end
