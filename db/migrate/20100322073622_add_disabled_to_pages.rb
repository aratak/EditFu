class AddDisabledToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :disabled, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pages, :disabled
  end
end
