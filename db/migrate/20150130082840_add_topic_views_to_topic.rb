class AddTopicViewsToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :views, :integer, default:0, null:false
  end
end
