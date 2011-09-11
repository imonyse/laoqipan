class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :game_id
      t.datetime :send_time

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
