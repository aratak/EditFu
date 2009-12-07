require 'spec_helper'

describe ConfirmationsController do
  include Devise::TestHelpers

  before :each do
    @owner = User.new :name => 'owner', :email => 'owner@malinator.com',
      :password => '123456', :confirmed_password => '123456'
    @owner.save!

    @editor = @owner.add_editor('editor@malinator.com')
  end

  describe "create and show" do
    it "should redirect to editor confirmation page if user is editor" do
      get :show, :confirmation_token => @editor.confirmation_token

      response.should redirect_to(
        edit_editor_confirmation_path(
          :confirmation_token => @editor.confirmation_token
        )
      )
      @editor.reload.confirmed?.should be_false
    end

    it "should allow owners to process user confirmations" do
      get :show, :confirmation_token => @owner.confirmation_token
      @owner.reload.confirmed?.should be_true
    end
  end
end
