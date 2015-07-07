class LoginController < PublicController
  skip_before_filter :get_user, only:[:logout]

  if Rails.env.development? && INSTALLED_LOGINS.detect{|k,v| v}.blank?
    def index
      if params[:email] && user = User.find_by_email(params[:email])
        session[:user_id] = user.id
        redirect_to '/'
      else
        render rails:true, layout:'application'
      end
    end
  end

  def login
    email = request.env["omniauth.auth"]['info']['email']
    user = User.find_by_email(email)
    if user.blank?
      session[:unregistered_email] = request.env["omniauth.auth"]['info']['email']
      redirect_to action: :register
    else
      session[:user_id] = user.id
      redirect_to '/'
    end
  end

  def register_conditions
    if session[:user_id]
      render text:"You are already registered. No need to do it twice!"
    elsif session[:unregistered_email].blank? || !(session[:unregistered_email] =~ /\@/)
      render text:"You can't register without having logged in first!"
    end
  end

  before_filter :register_conditions, only:[:register, :do_register]
  def register
    @email = session[:unregistered_email]
  end

  def do_register
    if !params[:name].is_a?(String) || params[:name].length < 2
      render text: 'Name too short.'
    else
      user = User.create(name:params[:name],email:session[:unregistered_email])
      reset_session
      session[:user_id] = user.id
      redirect_to '/'
    end
  end

  def logout
    reset_session
    redirect_to '/'
  end
end
