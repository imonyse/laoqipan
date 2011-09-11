class AddNotifyPenddingMoveToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_pendding_move, :boolean, :default => false
  end

  def self.down
    remove_column :users, :notify_pendding_move
  end
end
