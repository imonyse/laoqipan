class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.text :sgf
      t.string :name
      t.integer :mode, :default => 0
      t.integer :current_player_id
      t.integer :status, :default => 0
      t.integer :black_player_id
      t.integer :white_player_id

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
