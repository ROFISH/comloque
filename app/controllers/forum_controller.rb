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

  before_filter :require_forum, only:[:topiclist,:newtopic,:create_message,:topic,:edit_topic,:update_topic]
  before_filter :require_topic!, only:[:topic,:edit_topic,:update_topic]

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
    @topics = @forum.topics.order(last_posted_at: :desc).includes(:user)
    @topic_reads = @user.try(:topic_reads_for,@topics.map(&:id)) || {}
  end

  def newtopic
  end

  after_filter :touch_topic_read, only:[:topic], if: ->{@user && @topic}
  after_filter :update_topic_views, only:[:topic], if: ->{@user && @topic}
  def topic
  end

  before_filter :require_edit_topic_permission, only:[:edit_topic,:update_topic]
  def edit_topic
  end

  def update_topic
    updated_attrs = {}
    updated_attrs[:name] = params[:topic_name] if params[:topic_name]
    if @topic.can_mod?(@user)
      updated_attrs[:locked_at] = Time.now if @topic.unlocked? && params[:topic_locked] == "true"
      updated_attrs[:locked_at] = nil if @topic.locked? && params[:topic_locked] == "false"
    end
    @topic.update(updated_attrs)
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

  def require_edit_topic_permission
    render text:"You are not allowed to edit this topic.", layout:true, status: :forbidden unless @topic.can_edit?(@user)
  end

  def touch_forum_read
    if @user.forum_reads.where(forum_id:@forum.id).update_all(updated_at:Time.now) == 0
      @user.forum_reads.create(forum_id:@forum.id)
    end
  end

  def touch_topic_read
    if @user.topic_reads.where(topic_id:@topic.id).update_all(updated_at:Time.now) == 0
      @user.topic_reads.create(topic_id:@topic.id)
    end
  end

  def update_topic_views
    # :last_topic where we don't double count if you are loading twice
    Topic.where(id:@topic.id).update_all("views = COALESCE(views, 0) + 1") unless session[:last_topic] == @topic.id
    session[:last_topic] = @topic.id
  end
end
