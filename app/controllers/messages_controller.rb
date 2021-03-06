class MessagesController < ForumController
  before_filter :require_forum
  before_filter :require_topic!, except:[:create]
  before_filter :require_message!, except:[:create]

  def show
    respond_to do |format|
      format.json { render json: @message }
    end
  end

  before_filter :require_topic, only:[:create]
  before_filter :process_create_topic, only:[:create], if:->(x){ @topic.blank? }
  before_filter :process_create_message, only:[:create]
  def create
    redirect_to controller: :forum, action: :topic, topic: @topic.permalink, anchor:"message#{@message.id}"
  end

  before_filter :require_edit_message_permission, only:[:edit,:update]
  def edit
    @template_name = :edit_message
  end

  def update
    updated_attrs = {}
    updated_attrs[:body] = params[:message_body] if params[:message_body]
    @message.update(updated_attrs)
    redirect_to controller: :forum, action: :topic, topic: @topic.permalink, anchor:"message#{@message.id}"
  end

  before_filter :require_delete_message_permission, only:[:destroy]
  def destroy
    @message.destroy
    redirect_to controller: :forum, action: :topic, topic: @topic.permalink
  end

private

  def require_edit_message_permission
    render text:"You are not allowed to edit this post.", layout:true, status: :forbidden unless @message.can_edit?(@user)
  end

  def require_delete_message_permission
    render text:"You are not allowed to delete this post.", layout:true, status: :forbidden unless @message.can_delete?(@user)
  end

  def process_create_topic
    raise if !@forum.can_create_topic?(@user)
    @topic = Topic.create(name:params[:topic_name],forum_id:@forum.id,user_id:@user.id)
  end

  include CreateMessages
end
