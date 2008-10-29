require 'fileutils'

stats_config = File.dirname(__FILE__) + '/../../../config/stats_for_all.yml'
FileUtils.cp File.dirname(__FILE__) + '/templates/stats_for_all.yml', stats_config unless File.exist?(stats_config)

migrate_dir=File.dirname(__FILE__) + "/../../../db/migrate/"
Dir.mkdir( migrate_dir) unless File.exist?(migrate_dir)

migration_config = File.dirname(__FILE__) + "/../../../db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_create_stats_for_all.rb"
FileUtils.cp File.dirname(__FILE__) + '/templates/create_stats_for_all.rb', migration_config # unless File.exist?(migration_config)

puts IO.read(File.join(File.dirname(__FILE__), 'README.markdown'))

puts "##########################################################################################"
puts "###  Check the configuration file in /config/stats_for_all.yml"
puts "###  Run the migration ( rake db:migrate ) to create the new table to store stats"
puts "##########################################################################################"
