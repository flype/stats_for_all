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
    add_index :stats, [:day], :name =>"idx_stats_day"
    add_index :stats, [:month], :name =>"idx_stats_month"
    add_index :stats, [:year], :name =>"idx_stats_year"    
    add_index :stats, [:stat_type], :name =>"idx_stats_stat_type"    
  end

  def self.down
    drop_table :stats
  end
end
