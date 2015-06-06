class AddModNotesToReports < ActiveRecord::Migration
  def change
    add_column :reports, :mod_notes, :text
    if defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter && connection.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      change_column :reports,:mod_id, 'integer USING CAST("mod_id" AS integer)'
    else
      change_column :reports,:mod_id, :integer
    end
  end
end
