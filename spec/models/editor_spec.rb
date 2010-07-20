require 'spec_helper'

describe Editor do
  describe 'set_page_ids' do
    it "should assign only pages from owner sites" do
      editor = Factory.create(:editor)
      site = Factory.create(:site, :owner => editor.owner)
      page1 = Factory.create(:page, :site => site)
      page2 = Factory.create(:page)

      editor.set_page_ids [page1.id.to_s, page2.id.to_s] 
      editor.page_ids.should == [page1.id]
    end
  end

  describe 'sites' do
    it "should return actual editor sites" do
      editor = Factory.create(:editor)
      site1 = Factory.create(:site, :owner => editor.owner)
      site2 = Factory.create(:site, :owner => editor.owner)

      editor.pages << Factory.create(:page, :site => site1)
      editor.pages << Factory.create(:page, :site => site1)
      editor.pages << Factory.create(:page, :site => site2)

      editor.sites.should == [site1, site2]
    end
  end

  describe "trial_period_expired?" do
    it "should delegate to owner" do
      editor = Factory.create(:editor)
      editor.owner.should_receive(:trial_period_expired?).and_return(true)
      editor.trial_period_expired?.should be_true
    end
  end
end





# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  email                :string(100)     not null
#  encrypted_password   :string(40)
#  password_salt        :string(20)
#  confirmation_token   :string(20)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(20)
#  remember_token       :string(20)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  domain_name          :string(255)
#  owner_id             :integer(4)
#  type                 :string(10)      not null
#  enabled              :boolean(1)      default(TRUE), not null
#  user_name            :string(255)
#  company_name         :string(255)
#  plan_id              :integer(4)      default(1)
#

