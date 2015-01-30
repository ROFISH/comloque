class ConvertTopicIdToInteger < ActiveRecord::Migration
  def change
    Message.where("topic_id LIKE '#<%'").delete_all
    change_column :messages, :topic_id, 'integer USING CAST(topic_id AS integer)'
  end
end
