require 'test_helper'

class MovesControllerTest < ActionController::TestCase
  test "score request should correctly set game's score_request" do
    game = Factory(:game)
    player = game.current_player
    fake_sign_in player
    post :create, :game_id => game.id, :format => "js", :score => "1"
    assert_response :success, @response.body
    game.reload
    assert_equal(game.score_requester, player.id)
  end
  
  test "score request should reset if opponent rejected" do
    game = Factory(:game)
    player = game.current_player
    game.update_attributes(:score_requester => player.id)
    opponent = game.current_player == game.black_player ? game.white_player : game.black_player
    fake_sign_in opponent
    post :create, :game_id => game.id, :format => "js", :score => "0"
    game.reload
    assert_equal(game.score_requester, 0)
  end
end
