require File.expand_path(File.dirname(__FILE__) + "/../lib/stats_for_all/config_load")
require 'drb'

namespace :stats_for_all do
  desc "start the stats_for_all server"
  task :start do      
    system "ruby #{RAILS_ROOT}/vendor/plugins/stats_for_all/lib/stats_for_all/stats_for_all_server_demonized.rb start #{RAILS_ENV}"
  end

  desc "stop the stats_for_all server"
  task :stop do      

    puts "saving the stats to the db"
    DRb.start_service
    client_server = DRbObject.new(nil, "druby://#{StatsForAll::CONFIGURATION["server_host"]}:#{StatsForAll::CONFIGURATION["server_port"]}")
    client_server.final_save_all
    DRb.stop_service

    system "ruby #{RAILS_ROOT}/vendor/plugins/stats_for_all/lib/stats_for_all/stats_for_all_server_demonized.rb stop #{RAILS_ENV}"
  end

  desc "Run in foreground the stats_for_all server"
  task :run do      
    system "ruby #{RAILS_ROOT}/vendor/plugins/stats_for_all/lib/stats_for_all/stats_for_all_server_demonized.rb run #{RAILS_ENV}"
  end


end