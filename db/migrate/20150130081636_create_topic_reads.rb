class CreateTopicReads < ActiveRecord::Migration
  def change
    create_table :topic_reads do |t|
      t.integer :topic_id
      t.integer :user_id
      t.datetime :updated_at
    end
  end
end
