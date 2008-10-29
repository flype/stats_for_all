class CreateStatsForAll < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.references :model, :polymorphic => true
      t.integer  "stat_type", :null => false
      t.integer "day", "month", "year"
      t.text    "data"
      t.timestamps
    end
    execute "ALTER TABLE stats CHANGE COLUMN data data BLOB"
  end

  def self.down
    drop_table :stats
  end
end
