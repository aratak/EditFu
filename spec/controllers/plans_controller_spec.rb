require 'spec_helper'

describe PlansController do
  include Devise::TestHelpers

  before :each do
    @owner = Factory.create(:owner)
    @owner.confirm!
    sign_in :user, @owner
  end

  describe "#update" do
    it "should change plan to free" do
      s1 = Factory.create :site, :owner => @owner
      s2 = Factory.create :site, :owner => @owner
      p1 = Factory.create :page, :site => s1
      p2 = Factory.create :page, :site => s1
      p3 = Factory.create :page, :site => s2

      put :update, :owner => { :plan => 'free' },
        :sites => [ s1.id.to_s ],
        :pages => [ p1.id.to_s, p2.id.to_s ]
      response.should redirect_to(preferences_url)
      @owner.reload.sites.should == [s1]
      @owner.pages.should == [p1, p2]
    end
  end
end
