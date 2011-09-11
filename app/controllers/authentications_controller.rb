class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]
  
  def index
    @user = current_user
  end
  
  def create
    omniauth = request.env['omniauth.auth']
    # access_token = omniauth['extra']['access_token']
    # File.open(Rails.root.join('access_token').to_s, 'w') do |f|
    #   Marshal.dump(access_token, f)
    # end
    
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      user = authentication.user
      sign_in user
    else
      if user_signed_in?
        user = current_user
        user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      else
        user = User.new(:name => omniauth['uid']+'@'+omniauth['provider'])
        user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
        user.save(:validate => false)
        sign_in user
        flash[:notice] = I18n.t(:please_update_your_account)
        redirect_to edit_user_path(user)
        return
      end
    end
    
    redirect_to user_path(user)
  end
  
  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy
    
    redirect_to '/auth'
  end
end
