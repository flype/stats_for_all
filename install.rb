require 'fileutils'

stats_config = File.dirname(__FILE__) + '/../../../config/stats_for_all.yml'
FileUtils.cp File.dirname(__FILE__) + '/templates/stats_for_all.yml', stats_config unless File.exist?(stats_config)

migration_config = File.dirname(__FILE__) + "/../../../db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_stats_for_all.rb"
FileUtils.cp File.dirname(__FILE__) + '/templates/create_stats_for_all.rb', migration_config # unless File.exist?(migration_config)

puts IO.read(File.join(File.dirname(__FILE__), 'README'))
