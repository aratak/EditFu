class RenamePageDisabledToEnabled < ActiveRecord::Migration
  def self.up
    rename_column :pages, :disabled, :enabled
    change_column_default :pages, :enabled, true
    execute 'UPDATE pages SET enabled = !enabled'
  end

  def self.down
    rename_column :pages, :enabled, :disabled
    execute 'UPDATE pages SET disabled = !disabled'
  end
end
