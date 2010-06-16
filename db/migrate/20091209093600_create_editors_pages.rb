class CreateEditorsPages < ActiveRecord::Migration
  def self.up
    create_table :editors_pages, :id => false do |t|
      t.references :editor
      t.references :page
    end

    execute 'INSERT INTO editors_pages (editor_id, page_id) ' +
      'SELECT e.id, p.id FROM users e, sites s, pages p ' +
      'WHERE e.type = "Editor" AND e.owner_id = s.owner_id AND p.site_id = s.id'
  end

  def self.down
    drop_table :editors_pages
  end
end
