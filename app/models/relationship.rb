class Relationship < ActiveRecord::Base
  attr_accessible :followed_id
  
  belongs_to :follower, :class_name => "User"
  belongs_to :followed, :class_name => "User"
  
  validates_presence_of :follower_id, :on => :create
  validates_presence_of :followed_id, :on => :create
end

# == Schema Information
#
# Table name: relationships
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

