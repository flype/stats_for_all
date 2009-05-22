require 'test/unit'
require 'yaml'
require 'rubygems'
require 'daemons'
require 'active_record'
require 'drb'
require 'yaml'
require 'shoulda/rails'
require 'factory_girl'

module StatsForAll
  RAILS_ENV='test'
end

require 'stats_for_all'

ActiveRecord::Base.establish_connection(YAML.load_file(File.expand_path(File.dirname(__FILE__) + "../../../../../config/database.yml"))[StatsForAll::RAILS_ENV])

ActiveRecord::Base.send(:include, StatsForAll::Client)


def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table "banners", :force => true do |t|
      t.integer "user_id"
      t.string  "nombre"
      t.string  "path"
      t.string  "tipo"
      t.date    "t_inicio"
      t.date    "t_fin"
      t.string  "URL"
      t.string  "file"
      t.integer "click_counter"
    end
    create_table "stats", :force => true do |t|
      t.integer  "model_id"
      t.string   "model_type"
      t.integer  "stat_type",  :null => false
      t.integer  "day"
      t.integer  "month"
      t.integer  "year"
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    execute "ALTER TABLE stats CHANGE COLUMN data data BLOB"
    
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Banner < ActiveRecord::Base
  stats_for_me
end

Factory.define :banner do |b|
  b.nombre "my banner"
  b.path  "/banners/ban.gif"
  b.tipo "top-right"
  b.URL "http://localhost.com"
  b.file  "ban.gif"
  b.click_counter 0
end

Factory.define :stat do |s|
  s.stat_type 1
  s.model_id  1
  s.model_type "Banner"
  s.day 22
  s.month 11
  s.year 2007
  s.data  Marshal.dump(Array.new(24,0))
end