class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.integer :forum_id
      t.integer :user_id
      t.string :permalink

      t.timestamps
    end
  end
end
