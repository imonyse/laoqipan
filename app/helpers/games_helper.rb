module GamesHelper
  def game_div(game, &block)
    if !game.nil?
      options = {
        "id"             => "game",
        "sgf"            => game.sgf,
        "mode"           => game.mode,
        "access"         => game.access,
        "status"         => game.status,
        "current_player" => game.current_player.id,
        "black_player"   => game.black_player.id,
        "white_player"   => game.white_player.id,
        "requester"      => game.score_requester,
        "channel"        => game.id
      }
    
      @cur = current_user.id if current_user
      options.merge!(:current_user => @cur)
    else
      options = {
        "id"    => "game",
      }
    end
    
    content_tag(:div, options, &block)
  end
  
end
