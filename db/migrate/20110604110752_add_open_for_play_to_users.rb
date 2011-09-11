class AddOpenForPlayToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :open_for_play, :boolean, :default => true
    execute <<-SQL
      UPDATE users set OPEN_FOR_PLAY=true
    SQL
  end

  def self.down
    remove_column :users, :open_for_play
  end
end
