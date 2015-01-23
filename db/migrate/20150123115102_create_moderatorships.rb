class CreateModeratorships < ActiveRecord::Migration
  def change
    create_table :moderatorships do |t|
      t.integer :forum_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
