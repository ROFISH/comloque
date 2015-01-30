class AddCountersToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :messages_count, :integer, default:0, null:false
    add_column :topics, :last_posted_at, :datetime
  end
end
