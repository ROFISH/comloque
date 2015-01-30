class ForumController < PublicController

  # I'm not sure if this is the best place to put this? This is a very specific Drop for this controller
  class CategoryDrop < Liquid::Drop
    def initialize(category,forums)
      @category = category
      @forums = forums
    end

    def name
      @category.attributes['name']
    end

    def url
      @category.url
    end

    def forums
      @forums
    end
  end

  before_filter :require_forum, only:[:topiclist,:newtopic,:create_message,:topic,:edit_message,:update_message,:delete_message]
  before_filter :require_topic!, only:[:topic,:edit_message,:update_message,:delete_message]
  before_filter :require_message!, only:[:edit_message,:update_message,:delete_message]

  def index
    @forums = Forum.public_scope(@user).includes(:category)
    # this is a really complex way to get the forums in a category but it ensures two things
    # 1) user sees only forums the user is allowed to see
    # 2) user sees only categories containing forums the user is allowed to see
    categories = @forums.map{|x| x.category}.uniq
    @categories = categories.map{|cat| CategoryDrop.new(cat,@forums.select{|f| f.category_id == cat.id})}

    @forum_reads = @user.try(:forum_reads_for,@forums.map(&:id)) || {}
  end

  after_filter :touch_forum_read, only:[:topiclist], if: ->{@user && @forum}
  def topiclist
    @topics = @forum.topics.order(last_posted_at: :desc)
  end

  def newtopic
  end

  def topic
  end

  before_filter :require_edit_message_permission, only:[:edit_message,:update_message]
  def edit_message
  end

  def update_message
    updated_attrs = {}
    updated_attrs[:body] =  params[:message_body] if params[:message_body]
    @message.update(updated_attrs)
    redirect_to action: :topic, topic: @topic.permalink, anchor:"message#{@message.id}"
  end

  before_filter :require_delete_message_permission, only:[:delete_message]
  def delete_message
    @message.destroy
    redirect_to action: :topic, topic: @topic.permalink
  end

  before_filter :require_topic, only:[:create_message]
  before_filter :process_create_topic, only:[:create_message], if:->(x){ @topic.blank? }
  before_filter :process_create_message, only:[:create_message]
  def create_message
    redirect_to action: :topic, topic: @topic.permalink
  end

  # this shouldn't be in the forum_controller, but for now it lives here until better loginy pages can be made

private
  def require_forum
    @forum = Forum.find_by_permalink_and_category_permalink(params[:forum],params[:cat])
    raise ActiveRecord::RecordNotFound if @forum.blank?
  end

  def require_topic
    @topic = @forum.topics.find_by_permalink_and_scope_id(params[:topic],@forum.id)
  end

  def require_topic!
    require_topic
    raise ActiveRecord::RecordNotFound if @topic.blank?
  end

  def require_message
    require_topic!
    @message = @topic.messages.find(params[:message])
  end

  def require_message!
    require_message
    raise ActiveRecord::RecordNotFound if @message.blank?
  end

  def process_create_topic
    raise if !@forum.can_create_topic?(@user)
    @topic = Topic.create(name:params[:topic_name],forum_id:@forum.id,user_id:@user.id)
  end

  def process_create_message
    raise if !@topic.can_reply?(@user)
    @message = Message.create(body:params[:message_body],topic:@topic,user_id:@user.id)
  end

  def require_edit_message_permission
    render text:"You are not allowed to edit this post.", layout:true, status: :forbidden unless @message.can_edit?(@user)
  end

  def require_delete_message_permission
    render text:"You are not allowed to delete this post.", layout:true, status: :forbidden unless @message.can_delete?(@user)
  end

  def touch_forum_read
    if @user.forum_reads.where(forum_id:@forum.id).update_all(updated_at:Time.now) == 0
      @user.forum_reads.create(forum_id:@forum.id)
    end
  end
end
