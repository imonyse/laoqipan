class AddUploaderToGames < ActiveRecord::Migration
  def change
    add_column :games, :uploader, :integer
    add_column :games, :brief, :text
  end
end
