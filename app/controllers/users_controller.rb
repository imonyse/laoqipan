class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :validate_email, :following, :followers]
  before_filter :ensure_not_logged_in, :only => [:reset_password, :recover_password]
  
  def new
    if user_signed_in?
      flash[:notice] = I18n.t(:update_your_profile)
      redirect_to edit_user_url(current_user)
    end
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in(@user)
      redirect_to user_path(@user)
    else
      flash.now[:error] = @user.errors.full_messages
      render :action => 'new'
    end
  end
  
  def show
    @user = User.find(params[:id])
    
    if user_signed_in?
      @current_games = Game.where("black_player_id = '#{@user.id}' or white_player_id = '#{@user.id}'").order("case when current_player_id = '#{@user.id}' then 0 else 1 end, status, updated_at DESC").page(params[:current_games_page]).per(4)
      @games = Game.where("mode != 0 and access = 0 and black_player_id != #{@user.id} and white_player_id != #{@user.id}").order("updated_at DESC").page(params[:game_page]).per(4)
    else
      @games = Game.where("mode != 0 and access = 0").order("updated_at DESC").page(params[:game_page]).per(10)
    end
    
    @pro_game = Game.where("mode = 0").order('created_at DESC').first

  end
  
  def index
    @users = User.order(:rank).page(params[:page]).per(19)
  end
  
  def edit
    @user = current_user
    if params[:email]
      @user.email = params[:email]
    end
  end
  
  def update
    @user = current_user
    @attr = params[:user]
    if @attr[:open_for_play] == "true"
      @attr.merge!(:open_for_play => true)
    else
      @attr.merge!(:open_for_play => false)
    end
    
    @user.attributes = @attr
    if @user.save
      flash[:success] = I18n.t("profile_has_been_updated")
      redirect_to(user_path(@user))
    else
      flash.now[:error] = @user.errors.full_messages
      render "edit"
    end
  end
  
  def reset_password
  end
  
  def recover_password
    user = User.find_by_email(params[:user][:email])
    if user
      Mailer.recovery(:key => Crypto.encrypt("#{user.id}:#{user.salt}"),
                      :email => user.email, 
                      :domain => request.env['HTTP_HOST']).deliver
      redirect_to signin_url, :notice => t(:recovery_email_sent)
    else
      redirect_to reset_password_url, :alert => t(:email_user_not_exists)
    end
  end
  
  def validate_email
    user = current_user
    if user
      Mailer.confirm(:key => Crypto.encrypt("#{user.id}:#{user.salt}"),
                     :email => user.email, 
                     :domain => request.env['HTTP_HOST']).deliver
      redirect_to user_path(user), :notice => t(:confirmation_email_sent)
    end
  end
  
  def following
    @user = User.find(params[:id])
    @users = @user.following.page
    
    respond_to do |format|
      format.html { render 'show_follow' }
    end
  end
  
  def followers
    @user = User.find(params[:id])
    @users = @user.followers.page
    
    respond_to do |format|
      format.html { render 'show_follow' }
    end
  end
end
