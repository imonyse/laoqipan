class AddPushToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :push, :boolean, :default => false
    execute <<-SQL
      UPDATE broadcasts SET push = true
    SQL
  end
end
