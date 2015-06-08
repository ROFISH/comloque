class InboxController < PublicController
  before_filter :require_user!

  def index
    #ptu = @user.private_topic_users.includes(:topic)
    #readsmap = ptu.map{|x| [x.topic_id,x.last_read]}
    #@topic_reads = Hash[readsmap]
    #@private_topics = ptu.map(&:topic)
    @private_topics = @user.private_topics
    @topic_reads = @user.try(:topic_reads_for,@private_topics.map(&:id)) || {}
  end

  def new
  end

  before_filter :require_topic, only:[:create]
  before_filter :process_create_topic, only:[:create], if:->(x){ @topic.blank? }
  before_filter :process_create_message, only:[:create]
  before_filter :touch_topic_last_post, only:[:create]
  def create
    redirect_to action: :index
  end

  before_filter :require_topic!, only:[:show]
  after_filter :touch_topic_read, only:[:show], if: ->{@user && @topic}
  after_filter :update_topic_views, only:[:show], if: ->{@user && @topic}
  def show
  end

private

  def process_create_topic
    PrivateTopicUser.transaction do
      usernames = params[:topic_users].split(",").map(&:strip)
      users = []
      usernames.each do |username|
        user = User.where("lower(name) = ?",username.downcase).first
        raise "Unknown user: #{username}" if user.blank?
        users << user
      end
      users.reject!{|x| x.id == @user.id}
      raise if users.blank?

      @topic = Topic.create(name:params[:topic_name],forum_id:nil,user_id:@user.id)
      PrivateTopicUser.create(topic_id:@topic.id,user_id:@user.id,last_read:Time.utc(1999),last_message:Time.utc(1999))
      users.each do |user|
        PrivateTopicUser.create(topic_id:@topic.id,user_id:user.id,last_read:Time.utc(1999),last_message:Time.utc(1999))
      end
    end
  rescue Exception=>e
    render text:e.to_s, status: :not_found
  end

  def require_topic
    @topic = Topic.find_by_permalink_and_scope_id(params[:topic],nil)
    if @topic
      @ptu = PrivateTopicUser.find_by_user_id_and_topic_id(@user.id,@topic.id)
      @topic = nil if @ptu.blank?
    end
  end

  def require_topic!
    require_topic
    raise ActiveRecord::RecordNotFound if @topic.blank?
  end

  def touch_topic_read
    if @user.topic_reads.where(topic_id:@topic.id).update_all(updated_at:Time.now) == 0
      @user.topic_reads.create(topic_id:@topic.id)
    end
    PrivateTopicUser.where(topic_id:@topic.id,user_id:@user.id).update_all(last_read:Time.now)
  end

  def update_topic_views
    # :last_topic where we don't double count if you are loading twice
    Topic.where(id:@topic.id).update_all("views = COALESCE(views, 0) + 1") unless session[:last_topic] == @topic.id
    session[:last_topic] = @topic.id
  end

  def touch_topic_last_post
    PrivateTopicUser.where(topic_id:@topic).update_all(last_message:Time.now)
  end

  include CreateMessages
end
