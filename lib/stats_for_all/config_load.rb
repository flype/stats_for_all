require 'yaml'
module StatsForAll
  CONFIGURATION = {}
  
  def self.load_configuration()
    app_config_file = File.expand_path(File.dirname(__FILE__) + "../../../../../../config/stats_for_all.yml")

    # file config only loaded for the test environment
    app_config_file = File.expand_path(File.dirname(__FILE__) + "../../../test/stats_for_all.yml") if RAILS_ENV == "test"
    
    if File.exist?(app_config_file)
      CONFIGURATION.merge!(YAML.load(File.read(app_config_file))["all"] || {}) 
      CONFIGURATION.merge!(YAML.load(File.read(app_config_file))[RAILS_ENV || "test"] || {})
    end

    StatsForAll::CONFIGURATION["types"] ||= {}
  end
  
  def self.type(value)
    CONFIGURATION["types"].index(value)
  end
  
  def self.value(type)
    CONFIGURATION["types"].values_at(type).first
  end  
  
  def self.stat_type_storing_conversion(type)
    type.to_s
  end
end

StatsForAll.load_configuration
  