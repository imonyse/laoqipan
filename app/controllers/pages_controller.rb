class PagesController < ApplicationController
  def about
  end

  def feedback
  end

  def help
  end

  def index
    if user_signed_in?
      redirect_to user_path(current_user)
    end
    @games = Game.where("mode != 0 and access = 0").order("updated_at DESC").page(params[:game_page]).per(10)
  end
  
end
