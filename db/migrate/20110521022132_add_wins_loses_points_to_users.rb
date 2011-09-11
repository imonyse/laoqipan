class AddWinsLosesPointsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :wins, :integer, :default => 0
    add_column :users, :loses, :integer, :default => 0
    add_column :users, :points, :integer, :default => 0
  end

  def self.down
    remove_column :users, :points
    remove_column :users, :loses
    remove_column :users, :wins
  end
end
