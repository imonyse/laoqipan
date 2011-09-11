# == Schema Information
# Schema version: 20110712024750
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

require 'crypto'

class Notification < ActiveRecord::Base
  validates_uniqueness_of :game_id, :scope => :user_id
end
