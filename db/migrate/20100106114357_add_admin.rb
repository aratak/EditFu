class AddAdmin < ActiveRecord::Migration
  def self.up
    # password = KlatfildEabTerv
    execute "INSERT INTO users(name, email, type, " + 
      "encrypted_password, password_salt, confirmed_at)" +
      "VALUES('admin', 'admin@editfu.com', 'Admin', " + 
      "'9cead06f3fa4d7def6c26d10261571c9d47dac60', 'WYoI718OHZwUTbzQAKAE', " +
      "current_timestamp)"
  end

  def self.down
    execute "DELETE FROM users WHERE name = 'admin'"
  end
end
