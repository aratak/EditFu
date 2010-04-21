require 'spec_helper'

describe User do
  before :each do
    @user = Factory.create(:owner, :password => 'securekey', :password_confirmation => 'securekey')
    @user.password = @user.password_confirmation = nil
  end

  describe "#validate" do
    it "should require current password if user tries to change password" do
      @user.require_current_password
      @user.password_confirmation = @user.password = "123456"

      @user.save.should be_false
      @user.errors.on(:base).should  == I18n.t('passwords.blank.change')
    end

    it "shouldn't require current password if both password and confirmation are blank" do
      @user.require_current_password
      @user.save.should be_true
    end

    it "shouldn't require current password if require_current_password is not set" do
      @user.password_confirmation = @user.password = "123456"
      @user.save.should be_true
    end

    it "should require current password match" do
      @user.require_current_password
      @user.password_confirmation = @user.password = "123456"
      @user.current_password = 'invalid'
      
      @user.save.should be_false
      @user.errors.on(:base).should == I18n.t('passwords.current.invalid')
    end

    it "should work" do
      @user.require_current_password
      @user.password_confirmation = @user.password = "123456"
      @user.current_password = 'securekey'
      
      @user.save.should be_true
    end
  end
end
