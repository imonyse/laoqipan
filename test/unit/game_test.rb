require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # Replace this with your real tests.
end

# == Schema Information
#
# Table name: games
#
#  id                :integer         not null, primary key
#  sgf               :text
#  name              :string(255)
#  mode              :integer         default(0)
#  current_player_id :integer
#  status            :integer         default(0)
#  black_player_id   :integer
#  white_player_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#  access            :integer         default(3)
#  score_requester   :integer         default(0)
#  uploader          :integer
#  brief             :text
#

