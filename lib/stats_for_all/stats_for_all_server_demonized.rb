require 'rubygems'
require 'daemons'
require 'active_record'
require 'drb'
require 'yaml'                                                                 

module StatsForAll
  RAILS_ENV = ARGV.pop
end

require File.expand_path(File.dirname(__FILE__) + "../../../../../../config/environment")

ActiveRecord::Base.establish_connection(YAML.load_file(File.expand_path(File.dirname(__FILE__) + "../../../../../../config/database.yml"))[StatsForAll::RAILS_ENV])

stats_for_all = File.join(File.dirname(__FILE__), 'stats_for_all_runner.rb')
options = {
  :app_name => "stats_for_all_server",
  :ARGV => ARGV,
  :dir_mode => :normal,
  :dir => 'log',
  :log_output => true,
  :multiple => true,
  :backtrace => true,
  :monitor => false
}
Daemons.run(stats_for_all, options)