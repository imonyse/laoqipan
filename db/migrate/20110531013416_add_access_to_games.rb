class AddAccessToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :access, :integer, :default => 3
  end

  def self.down
    remove_column :games, :access
  end
end
