class ForumController < PublicController
  before_filter :require_forum, :only=>[:topiclist]
  def index
    @forums = Forum.all.to_a
  end

  def topiclist
  end

private
  def require_forum
    permalink = Permalink.find_by_name_and_thang_type(params[:forum],"Forum")
    raise ActiveRecord::RecordNotFound if permalink.blank?

    @forum = permalink.thang
  end
end
