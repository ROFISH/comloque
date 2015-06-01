class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :user_id
      t.string :mod_id
      t.datetime :resolved_at
      t.string :resolution_actions
      t.integer :message_id
      t.text :reason
      t.text :resolution

      t.timestamps null: false
    end
  end
end
