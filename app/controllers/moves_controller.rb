class MovesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    if current_user == @game.black_player or current_user == @game.white_player
      if @game.score_requester != 0 and current_user.id != @game.score_requester
        @pop_scoring = true
      end
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def create
    @game = Game.find(params[:game_id])
    @sgf = params[:sgf]
    @moves = params[:moves]
    @score = params[:score]
    @attr = {:sgf => @sgf}
    
    if current_user != @game.black_player and current_user != @game.white_player
      redirect_to game_path(@game), :alert => "xoxo"
      return
    end
    
    if params[:player_id]
      if current_user != @game.current_player
        redirect_to game_path(@game), :alert => "bug?"
        return
      end
      # so this is a normal move, player_id is used for switching current_player
      @current_player_id = params[:player_id].to_i
      if @game.current_player.id != @current_player_id
        redirect_to game_path(@game), :alert => "illegal move creation"
        return
      end
      
      if @game.current_player == @game.black_player
        @next_player = @game.white_player
      else
        @next_player = @game.black_player
      end
      
      @attr.merge!(:current_player => @next_player)
      if @game.access == 3
        # a game without any moves, as a default action, we make it public accessible
        @attr.merge!(:access => 0)
      end
      
      Game.transaction do
        @game.update_attributes(@attr)
        
        expired_notification = Notification.find_by_user_id_and_game_id(@current_player_id, @game.id)
        if expired_notification
          expired_notification.destroy
        end
      
        if @next_player and @next_player.notify_pendding_move
          if @next_player.email.present? and @next_player.email_confirmed
            Notification.create(:user_id => @next_player.id, :game_id => @game.id, :send_time => 1.hour.from_now)
          end
        end
      end
      
      Stalker.enqueue('generate_thumbnail', :game_id => @game.id, :game_sgf => @game.sgf, :thumb_path => @game.thumbnail_path)
      
      if @game.status == 0 and @game.vs_ai?
        @game.who_is_ai.last_request_at = Time.now
        @game.who_is_ai.save
        color = @game.current_player == @game.black_player ? 'black' : 'white'
        Stalker.enqueue("ai_move", :game_id => @game.id, :game_sgf => @game.sgf, :color => color)
      end
      
    else
      # post requests without player_id are final_score request
      if @score != nil
        requester = current_user
        if @score == "1" and @game.score_requester == 0
          @game.update_attributes(:score_requester => requester.id)
        else
          # this make sure only one scoring request will send to queue
          if @score == "1" and @game.score_requester != requester.id
            # opponent player accept score request
            if @game.status == 0
              Stalker.enqueue("score_game", :game_id => @game.id, 
                              :game_sgf => @game.sgf)
            end
          elsif @score == "0"
            # score request rejected
            @game.update_attributes(:score_requester => 0)
          end
        end
      else
        if @moves
          # this is a resign request
          Game.transaction do
            if @moves == "BRESIGN" and @game.status == 0
              @game.black_player.update_attributes(:loses => @game.black_player.loses + 1)
              @game.white_player.update_attributes(:wins => @game.white_player.wins + 1)
            elsif @moves == "WRESIGN" and @game.status == 0
              @game.white_player.update_attributes(:loses => @game.white_player.loses + 1)
              @game.black_player.update_attributes(:wins => @game.black_player.wins + 1)
            elsif @moves == "records"
              # this is a thumbnail generation request for sgf record games
              @attr = {:access => 0}
            end
            @attr.merge!({:status => 1})
            @game.update_attributes(@attr)
          end
        end
      end
    end
    
    request_receiver = 0
    if @game.score_requester == @game.black_player.id
      request_receiver = @game.white_player.id
    elsif @game.score_requester == @game.white_player.id
      request_receiver = @game.black_player.id
    end
      
    Juggernaut.publish(@game.id.to_s, {
      "type" => "move", 
      "sgf" => @game.sgf, 
      "current_player" => @game.current_player.id,
      "status" => @game.status,
      "access" => @game.access,
      "score_requester" => @game.score_requester,
      "request_receiver" => request_receiver.to_s
      })
    
    if @next_player
      Juggernaut.publish(@next_player.id.to_s, {
        "type" => "turn"
      })
    end
    
    respond_to do |format|
      format.js
    end
  end
  
end
