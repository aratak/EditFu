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
