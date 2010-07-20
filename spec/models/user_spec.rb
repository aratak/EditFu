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

