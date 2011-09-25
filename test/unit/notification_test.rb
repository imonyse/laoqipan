require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  game_id    :integer
#  send_time  :datetime
#  created_at :datetime
#  updated_at :datetime
#

