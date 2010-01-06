# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100106114357) do

  create_table "editors_pages", :force => true do |t|
    t.integer "editor_id"
    t.integer "page_id"
  end

  create_table "pages", :force => true do |t|
    t.integer "site_id", :null => false
    t.string  "path",    :null => false
    t.text    "content"
  end

  create_table "sites", :force => true do |t|
    t.string  "name",      :null => false
    t.string  "server",    :null => false
    t.string  "site_root", :null => false
    t.string  "login"
    t.string  "password"
    t.integer "owner_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                :limit => 100,                      :null => false
    t.string   "encrypted_password",   :limit => 40
    t.string   "password_salt",        :limit => 20
    t.string   "confirmation_token",   :limit => 20
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token", :limit => 20
    t.string   "remember_token",       :limit => 20
    t.datetime "remember_created_at"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "owner_id"
    t.string   "type",                 :limit => 10,                       :null => false
    t.string   "plan",                                :default => "trial"
    t.string   "card_number",          :limit => 20
    t.string   "subscription_id",      :limit => 13
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
