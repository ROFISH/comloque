class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_admin
  def require_admin
    if session[:user_id].is_a?(Integer)
      @user = User.find(session[:user_id])
    end
    render text:"You must be an admin to view the admin pages." unless @user.try(:is_admin?)
  end
end
