class GamesController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :authenticate?, :only => [:destroy]
  before_filter :only => [:edit, :update] { authenticate_admin(root_url) }
  
  def index
    respond_to do |format|
      format.html { @feed_items = Game.feed_items.page(params[:page]).per(10) }
    end
  end
  
  def records
    @games = Game.records.page(params[:page]).per(24)
    
    respond_to do |format|
      format.html
    end
  end

  def show
    begin
      @game = Game.find(params[:id])
      @comments = @game.comments.page(params[:comments_page]).per(9)
      
      if user_signed_in?
        @current_games = Game.current_games(current_user.id).page(params[:current_games_page]).per(4)
        @users = User.on_play_list(current_user.id).page(params[:page]).per(19)
      else
        @users = User.where("open_for_play = true").order("last_request_at DESC").page(params[:page]).per(19)
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_url
      return
    end
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @game = Game.new
    respond_to do |format|
      if params[:opponent]
        @opponent_name = params[:opponent]
        @game.opponent = @opponent_name
        if current_user == User.find_by_name(@opponent_name)
          format.html {render :text => I18n.t(:cannot_duel_with_yourself), :status => 403}
        else
          format.html
        end
      else
        format.html { render :text => I18n.t(:chose_opponent_msg), :status => 500 }
      end
    end
  end

  def create
    @attr = params[:game] || {}
    mode = @attr[:mode] || "0"
    @pb = @pw = @pc = nil
    @sgf = nil

    if mode == "0"
      if params[:sgf_url] != ""
        require 'sgf'
        sgf_url = params[:sgf_url]
        fetched_sgf = fetch_tom_sgf(sgf_url)

        @attr.merge!({:sgf => fetched_sgf,
                      :mode => 0, 
                      :access => 3})
      elsif params[:raw_sgf] != ""
        @attr.merge!({:sgf => params[:raw_sgf],
                      :mode => 0,
                      :access => 3})
      end
      
      @game = Game.new(@attr)
      if @game.save
        Stalker.enqueue('generate_thumbnail', :game_id => @game.id, :game_sgf => @game.sgf, :thumb_path => @game.thumbnail_path)
        redirect_to(game_path(@game))
      else
        flash.now[:alert] = t(:failed_to_create_game)
        render :action => :upload_sgf
      end
    else
      if mode == "1"
        @pc = @pb = User.find_by_name(@attr[:opponent])
        @pw = current_user
        @sgf = "(;FF[4]GM[1]SZ[19]RU[Japanese]KM[6.5]PB[#{@pb.name}]PW[#{@pw.name}])"
      elsif mode == "2"
        @pc = @pw = User.find_by_name(@attr[:opponent])
        @pb = current_user
        @sgf = "(;FF[4]GM[1]SZ[19]RU[Chinese]KM[0]HA[2]PB[#{@pb.name}]PW[#{@pw.name}]AB[pd][dp]AW[dd][pp])"
      end
      
      if @pw == @pb
        flash[:error] = I18n.t(:cannot_duel_with_yourself)
        respond_to do |format|
          format.html { render :text => "can't duel with yourself", :status => 403 }
        end
        return
      end
    
      @attr.merge!({:black_player => @pb, 
                    :white_player => @pw,
                    :current_player => @pc,
                    :sgf => @sgf})
      @game = Game.create(@attr)
      
      respond_to do |format|
        if @game.save
          if @game.status == 0 and @game.current_player.robot?
            color = @game.current_player == @game.black_player ? 'black' : 'white'
            Stalker.enqueue("ai_move", :game_id => @game.id, :game_sgf => @game.sgf, :color => color)
          end
          format.html { redirect_to game_url(@game) }
        else
          format.html { render :text => "failed to create game", :status => 500 }
        end
      end
    end
  end
  
  def edit
    @game = Game.find(params[:id])
  end
  
  def update
    @game = Game.find(params[:id])
    @attr = params[:game]
    
    respond_to do |format|
      if @game.update_attributes(@attr)
        format.html { redirect_to @game }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    @current_games = current_user.current_games
    respond_to do |format|
      format.js
    end
  end
  
  def authenticate?
    @game = Game.find(params[:id])
    if (!user_signed_in?)
      redirect_to root_url and return
    end
    
    if (current_user != @game.black_player) && (current_user != @game.white_player)
      redirect_to user_path(current_user), :alert => I18n.t(:access_denied) and return
    end
    
    if @game.access != 3
      redirect_to user_path(current_user), :alert => I18n.t(:access_denied) and return
    end
  end
  
  def duel
    @robot = User.where('role=98').first
    if user_signed_in?
      @users = User.where("id != #{current_user.id} and open_for_play = true and role != 98").order("last_request_at DESC").page(params[:page]).per(19)
    else
      @users = User.where("open_for_play = true and role != 98").order("last_request_at DESC").page(params[:page]).per(19)
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  def sgf
    @game = Game.find_by_id(params[:id])
    render :text => @game.sgf, :content_type => 'application/x-go-sgf'
  end
  
  def upload_sgf
    @game = Game.new(:mode => 0)
    
    respond_to do |format|
      format.html
    end
  end
  
  def current_games
    if params[:user_id]
      user = User.find(params[:user_id])
    else
      user = current_user
    end
    
    @current_games = Game.current_games(user.id).page(params[:current_games_page]).per(4)
    
    respond_to do |format|
      format.js
    end
  end
  
end
