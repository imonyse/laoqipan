class AddConnectedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :connected, :integer, :default => 0
    execute "update users set connected=0"
  end

  def self.down
    remove_column :users, :connected
  end
end
