class ChangeUsersRankType < ActiveRecord::Migration
  def up
    remove_column :users, :rank
    add_column :users, :level, :integer, :default => 0
  end

  def down
    add_column :users, :rank, :string, :default => "0"
    remove_column :users, :level
  end
end
