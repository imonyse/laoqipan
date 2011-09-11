class ThumbnailsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @image_data = params[:image_data]
    if @image_data
      @game.save_thumbnail(@image_data)
    end
    
    respond_to do |format|
      format.js
    end
  end
end
