class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.string :title
      t.text :body
      t.text :brief
      t.integer :author

      t.timestamps
    end
  end
end
