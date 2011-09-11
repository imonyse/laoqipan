class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user.nil?
      flash.now[:error] = I18n.t(:invalid_login_info)
      render :action => 'new'
    else
      if params[:session][:cookies] == "1"
        sign_in_as_cookie user
      else
        sign_in user
      end
      redirect_back_or user_path(user)
    end
  end
  
  def destroy
    sign_out
    redirect_to root_url
  end

  def recovery
    key = Crypto.decrypt(params[:format]).split(/:/)
    user = User.authenticate_with_salt(key[0], key[1])
    if user
      sign_in user
      redirect_to edit_user_path(user)
    else
      redirect_to signin_path, :alert => I18n.t(:invalid_recovery_link)
    end
  end
  
  def confirm_email
    key = Crypto.decrypt(params[:format]).split(/:/)
    user = User.authenticate_with_salt(key[0], key[1])
    if user
      user.update_attributes(:email_confirmed => true)
      sign_in user
      flash[:success] = I18n.t(:email_confirmed)
      redirect_to user_path(user)
    else
      redirect_to signin_path, :alert => I18n.t(:invalid_confimation_link)
    end
  end
  
  def handle_notify
    key = Crypto.decrypt(params[:key]).split(/:/)
    user = User.authenticate_with_salt(key[0], key[1])
    game_id = params[:game_id]
    if user and game_id
      sign_in user
      redirect_to game_path(game_id)
    end
  end
end
