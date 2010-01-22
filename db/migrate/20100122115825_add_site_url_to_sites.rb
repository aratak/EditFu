class AddSiteUrlToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :site_url, :string, :limit => 50
  end

  def self.down
    remove_column :sites, :site_url
  end
end
