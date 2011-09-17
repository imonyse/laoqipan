module SessionsHelper
  def sign_in(user)
    session[:user] = {:user_id => user.id, :user_salt => user.salt}
    current_user = user
  end
  
  def sign_in_as_cookie(user)
    cookies.signed[:user] = { :value => [user.id, user.salt], :expires => 30.days.from_now }
    sign_in user
  end
  
  def sign_out
    cookies.delete(:user)
    reset_session
    current_user = nil
  end
  
  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.authenticate_with_salt(session[:user][:user_id], session[:user][:user_salt]) if session[:user]
    
    if !@current_user
      @current_user ||= User.authenticate_with_salt(*cookies.signed[:user]) if cookies.signed[:user]
    end
    
    @current_user
  end
  
  def user_signed_in?
    return true if current_user
  end
  
  def correct_user?(user)
    if current_user == user
      return true
    else
      return false
    end
  end
  
  def authenticate_user!
    if !current_user
      store_location
      redirect_to signin_url, :alert => I18n.t(:login_to_proceed)
    end
  end
  
  def authenticate_admin(back_url)
    user = current_user
    if not (user and user.admin?)
      redirect_to(back_url)
    end
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def login_required
    unless user_signed_in?
      flash[:alert] = t(:login_to_proceed)
      store_location
      redirect_to signin_url
    end
  end
  
  def ensure_not_logged_in
    if user_signed_in?
      flash[:alert] = t(:you_are_already_logged_in)
      redirect_to edit_user_path(current_user)
    end
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
  
  private
  
    def store_location
      session[:return_to] = request.fullpath
    end
    
end
