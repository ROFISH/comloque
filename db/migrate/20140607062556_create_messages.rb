class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :topic_id
      t.text :body
      t.integer :user_id

      t.timestamps
    end
  end
end
