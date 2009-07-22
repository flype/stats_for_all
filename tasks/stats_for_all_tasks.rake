require File.expand_path(File.dirname(__FILE__) + "/../lib/stats_for_all/config_load")
require 'drb'

namespace :stats_for_all do
  desc "start the stats_for_all server"
  task :start do      
    system "ruby #{RAILS_ROOT}/vendor/plugins/stats_for_all/lib/stats_for_all/stats_for_all_server_demonized.rb start #{RAILS_ENV}"
    puts "[STATS_FOR_ALL] Running"
  end

  desc "stop the stats_for_all server"
  task :stop do          
    DRb.start_service
    client_server = DRbObject.new(nil, "druby://#{StatsForAll::CONFIGURATION["server_host"]}:#{StatsForAll::CONFIGURATION["server_port"]}")
    if (client_server.connected? rescue false)
      puts "[STATS_FOR_ALL] saving the stats to the db"
      begin
      client_server.final_save_all 
      rescue => e
         puts "[STATS_FOR_ALL] something went wrong while you were saving :-(\n Error => #{e}"
      end
    else
      puts "[STATS_FOR_ALL] The stats_for_all daemon wasn't working"
    end
    DRb.stop_service

    system "ruby #{RAILS_ROOT}/vendor/plugins/stats_for_all/lib/stats_for_all/stats_for_all_server_demonized.rb stop #{RAILS_ENV}"
  end

  desc "Run in foreground the stats_for_all server"
  task :run do      
    system "ruby #{RAILS_ROOT}/vendor/plugins/stats_for_all/lib/stats_for_all/stats_for_all_server_demonized.rb run #{RAILS_ENV}"
  end

  desc "restart the stats_for_all server"
  task :restart => [:stop, :start]
end
