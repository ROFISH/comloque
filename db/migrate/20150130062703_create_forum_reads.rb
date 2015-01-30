class CreateForumReads < ActiveRecord::Migration
  def change
    create_table :forum_reads do |t|
      t.integer :forum_id
      t.integer :user_id
      t.datetime :updated_at
    end
  end
end
