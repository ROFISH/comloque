module CreateMessages
private

  def process_create_message
    raise if !@topic.can_reply?(@user)
    Message.transaction do
      @message = Message.create(body:params[:message_body],topic:@topic,user_id:@user.id)
      topic_updated_attrs = {}
      if @topic.can_mod?(@user)
        topic_updated_attrs[:locked_at] = Time.now if @topic.unlocked? && params[:topic_locked] == "true"
        topic_updated_attrs[:locked_at] = nil if @topic.locked? && params[:topic_locked] == "false"
      end
      @topic.update(topic_updated_attrs) unless topic_updated_attrs.blank?
    end
  end
end
