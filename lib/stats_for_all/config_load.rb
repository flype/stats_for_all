require 'yaml'
module StatsForAll
  CONFIGURATION = {}
  RAILS_ENV = Rails.env rescue "test"
  # RAILS_ROOT = 
  
  def self.load_configuration()
    app_config_file = File.expand_path(File.dirname(__FILE__) + "../../../../../../config/stats_for_all.yml")

    # file config only loaded for the test environment
    app_config_file = File.expand_path(File.dirname(__FILE__) + "../../../test/stats_for_all.yml") if RAILS_ENV == "test"

    
    if File.exist?(app_config_file)
      CONFIGURATION.merge!(YAML.load(File.read(app_config_file))["all"] || {}) 
      CONFIGURATION.merge!(YAML.load(File.read(app_config_file))[RAILS_ENV || "test"] || {})
    end
  end
end

StatsForAll.load_configuration
  