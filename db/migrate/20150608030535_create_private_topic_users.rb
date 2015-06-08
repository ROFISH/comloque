class CreatePrivateTopicUsers < ActiveRecord::Migration
  def change
    create_table :private_topic_users do |t|
      t.integer :topic_id, null:false
      t.integer :user_id, null:false
      t.datetime :last_read, null:false
      t.datetime :last_message, null:false

      t.timestamps null: false
    end
  end
end
