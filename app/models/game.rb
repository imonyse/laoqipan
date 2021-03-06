# @mode : 0 => uploads, 1 => modern style game, 2 => traditional style game
# @status : 0 => on going game, 1 => finished game
# @access : 0 => public, 1 => private, 3 => protected
class Game < ActiveRecord::Base
  attr_accessible :sgf, :moves, :mode, :access, :status, :name, :score_requester,
                  :current_player, :black_player, :white_player, :opponent, :uploader,
                  :brief
  attr_accessor :opponent
                  
  belongs_to :current_player, :class_name => "User"
  belongs_to :black_player, :class_name => "User"
  belongs_to :white_player, :class_name => "User"
  has_many :comments, :order => "created_at DESC"
  belongs_to :uploader, :class_name => "User"

  validates_inclusion_of :mode, :in => [0, 1 ,2]
  validates_inclusion_of :status, :in => [0, 1]
  
  validates_presence_of :sgf, :on => :create, :message => I18n.t(:no_sgf_msg)
  validates_length_of :sgf, :maximum => 1.megabyte, :on => :create, :message => I18n.t(:sgf_length_msg)
  
  scope :feed_items, where("mode != 0 and access = 0").order("updated_at DESC")
  scope :records, where("mode = 0").order("updated_at DESC")
  scope :current_games, lambda { |user_id| where("black_player_id = '#{user_id}' or white_player_id = '#{user_id}'").order("case when status = 3 then 0 when status = 0 then 1 else 2 end, case when current_player_id = '#{user_id}' then 0 else 1 end, status, updated_at DESC")}
  scope :uploads, where("mode = 0").order('created_at DESC')
  
  def thumbnail_path
    dir = File.expand_path("public/system/thumbnails", Rails.root.to_s)
    year, month, day = self.created_at.year, self.created_at.month, self.created_at.day
    dir = dir + "/#{year}/#{month}/#{day}"
    FileUtils.makedirs(dir)
    
    path = dir+"/#{self.id}.png"

    return path
  end
  
  def thumbnail
    path = "/system/thumbnails/#{self.created_at.year}/#{self.created_at.month}/#{self.created_at.day}/#{self.id}.png"
    if File.exists?("#{Rails.root.to_s}/public#{path}")
      return path + "?#{self.updated_at.to_s(:number)}"
    else
      return "default_board.png"
    end
  end
  
  def display_color(user)
    if current_player == user and status != 1
      "my_turn"
    else
      "others_turn"
    end
  end
  
  def vs_ai?
    black_player.robot? || white_player.robot?
  end
  
  def who_is_ai
    if black_player.robot?
      black_player
    elsif white_player.robot?
      white_player
    end
  end
  
  def continue_move_if_ai
    color = current_player == black_player ? 'black' : 'white'
    Stalker.enqueue("ai_move", :game_id => id, :game_sgf => sgf, :color => color)
  end
  
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  private
  
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
      where("black_player_id IN (#{followed_ids}) OR white_player_id IN (#{followed_ids})", {:user_id => user}).order("updated_at DESC")
    end
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

