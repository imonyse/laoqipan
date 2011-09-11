class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create]
  
  def index
    @game = Game.find(params[:game_id])
    @comments = @game.comments.page(params[:comments_page]).per(16)
    respond_to do |format|
      format.js
    end
  end
  
  def create
    @game = Game.find(params[:game_id])
    @old_comments = @game.comments
    @attr = params[:comment]
    @comment = @game.comments.build(@attr.merge(:user_id => current_user.id))
    
    @comment.save
    Juggernaut.publish(@game.id.to_s, {"type" => "comment"})
    respond_to do |format|
      format.js
    end
  end
  
end
