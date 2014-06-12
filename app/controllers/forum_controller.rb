class ForumController < PublicController
  before_filter :require_forum, only:[:topiclist,:newtopic,:create_message,:topic]
  before_filter :require_topic!, only:[:topic]
  def index
    @forums = Forum.all.to_a
  end

  def topiclist
    @topics = @forum.topics
  end

  def newtopic
  end

  def topic
  end

  before_filter :require_topic, only:[:create_message]
  before_filter :process_create_topic, only:[:create_message], if:->(x){ @topic.blank? }
  before_filter :process_create_message, only:[:create_message]
  def create_message
    redirect_to action: :topic, topic: @topic.permalink
  end

  # this shouldn't be in the forum_controller, but for now it lives here until better loginy pages can be made
  def login
    email = request.env["omniauth.auth"]['info']['email']
    user = User.find_by_email(email)
    if user.blank?
      # TODO: let the user select their own username
      user = User.create(name:email,email:email)
    end
    session[:user_id] = user.id
    redirect_to action: :index
  end

  def logout
    reset_session
    redirect_to action: :index
  end

private
  def require_forum
    @forum = Forum.find_by_permalink(params[:forum])
    raise ActiveRecord::RecordNotFound if @forum.blank?
  end

  def require_topic
    @topic = Topic.find_by_permalink_and_scope_id(params[:topic],@forum.id)
  end

  def require_topic!
    require_topic
    raise ActiveRecord::RecordNotFound if @topic.blank?
  end

  def process_create_topic
    raise if @user.nil?
    @topic = Topic.create(name:params[:topic_name],forum_id:@forum.id,user_id:@user.id)
  end

  def process_create_message
    raise if @user.nil?
    @message = Message.create(body:params[:message_body],topic_id:@topic,user_id:@user.id)
  end
end
