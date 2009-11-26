class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.references :site, :null => false
      t.string :path, :null => false
      t.text :content
    end
  end

  def self.down
    drop_table :pages
  end
end
