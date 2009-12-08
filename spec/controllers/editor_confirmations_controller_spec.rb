require 'spec_helper'

describe EditorConfirmationsController do
  include Devise::TestHelpers

  before :each do
    @owner = Owner.new :name => 'owner', :email => 'owner@malinator.com',
      :password => '123456', :confirmed_password => '123456'
    @owner.save!

    @editor = @owner.add_editor('editor@malinator.com')
  end

  describe "create" do
    it "should work" do
      post :create, :confirmation_token => @editor.confirmation_token, 
        :editor => {
          :name => 'Sergey', 
          :password => '123456', :password_confirmation => '123456'
        }

      response.should redirect_to(root_path)
      @editor.reload.confirmed?.should be_true
    end

    it "should reject site owners" do
      post :create, @owner.attributes

      response.should redirect_to(root_path)
      assigns(:editor).should be_nil
    end

    it "should run password validations" do
      post :create, :confirmation_token => @editor.confirmation_token, 
        :editor => { :name => 'Sergey' }

      assigns(:editor).confirmed?.should be_false
      response.should render_template(:edit)
    end

    it "should not allow to change email" do
      post :create, :confirmation_token => @editor.confirmation_token, 
        :editor => {
          :name => 'Sergey', :email => 'new_email@malinator.com',
          :password => '123456', :password_confirmation => '123456'
        }

      @editor.reload.email.should == 'editor@malinator.com'
    end
  end
end
