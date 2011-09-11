class AddScoreRequesterToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :score_requester, :integer, :default => 0
    Game.update_all ["score_requester = ?", 0]
  end

  def self.down
    remove_column :games, :score_requester
  end
end
