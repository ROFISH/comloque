class AddScopeIdToPermalinks < ActiveRecord::Migration
  def change
    add_column :permalinks, :scope_id, :integer
  end
end
