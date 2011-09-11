# == Schema Information
# Schema version: 20110709084329
#
# Table name: comments
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  game_id    :integer
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :users
  belongs_to :games
  
  validates_presence_of :content, :on => :create
end
