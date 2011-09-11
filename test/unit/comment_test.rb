require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "comment has correct associations" do
    game = Factory(:game)
    user = game.current_player
    comment = game.comments.create(:user_id => user.id, :content => "Howdy?")
    assert(user.comments.last.content, comment.content)
    assert(game.comments.last.content, comment.content)
  end
end
