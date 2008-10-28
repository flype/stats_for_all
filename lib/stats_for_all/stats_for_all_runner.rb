require 'drb'
require File.expand_path(File.dirname(__FILE__) + '../../stats_for_all')

class StatsForAllRunner
  def start
    print "Starting SuperStat drb server...."
    DRb.start_service("druby://#{StatsForAll::CONFIGURATION["server_host"]}:#{StatsForAll::CONFIGURATION["server_port"]}", StatsForAllServer.new)
    puts " done running in #{DRb.uri}"
  end

  def join
    DRb.thread.join
  end

  def loop_dump
    DRb.start_service
    client_server = DRbObject.new(nil, "druby://#{StatsForAll::CONFIGURATION["server_host"]}:#{StatsForAll::CONFIGURATION["server_port"]}")
    client_server.loop_process
    DRb.stop_service
    # DRb.thread.join
  end
end

s = StatsForAllRunner.new
s.start
s.loop_dump
s.join