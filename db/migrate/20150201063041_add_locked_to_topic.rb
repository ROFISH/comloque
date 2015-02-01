class AddLockedToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :locked_at, :datetime
  end
end
