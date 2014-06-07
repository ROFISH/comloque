class ForumController < PublicController
  before_filter :require_forum, :only=>[:topiclist]
  def index
    @forums = Forum.all.to_a
  end

  def topiclist
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
end
