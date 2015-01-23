class AddCreateTopicMessageToForums < ActiveRecord::Migration
  def change
    add_column :forums, :allow_create_topic, :boolean, null: false, default: true
    add_column :forums, :allow_create_message, :boolean, null: false, default: true
  end
end
