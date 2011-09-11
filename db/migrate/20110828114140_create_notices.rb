class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.text :body
      t.string :lang

      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
