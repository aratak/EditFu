class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name, :null => false
      t.string :server, :null => false
      t.string :site_root, :null => false
      t.string :login
      t.string :password
    end
  end

  def self.down
    drop_table :sites
  end
end
