class ForumController < PublicController
  def index
    @forums = Forum.all.to_a
  end
end
