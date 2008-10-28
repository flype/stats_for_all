require 'stats_for_all'

ActiveRecord::Base.send(:include, StatsForAll::Client)

