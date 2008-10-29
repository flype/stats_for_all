require 'drb'
module StatsForAll
  module Client

    def self.included(base) 
      base.extend ClassMethods 
    end 

    module ClassMethods 
      def stats_for_me(options={})
        has_many :stats, :dependent => :destroy, :as => :model

        include StatsForAll::Client::InstanceMethods 
      end
    end

    module InstanceMethods 
      
      # cool syntax stats retrieve supported!, like:
      # Object.stat :type=> Stat::TYPE[:click], :day => 21..24, :month =>10..12, :year => 2007..2009
      # Object.stat :type=> Stat::TYPE[:click], :day => 21, :month =>10, :year => 2008
      # Object.stat :type=> Stat::TYPE[:click], :month =>10, :year => 2008
      # Object.stat :type=> Stat::TYPE[:click], :year => 2008
      def stat(arg={})
        raise(ArgumentError, "type is a mandatory argument") unless arg[:type]          
        stats_array= stats.day(arg[:day]).month(arg[:month]).year(arg[:year]).stats_type(arg[:type]).map { |stat| stat.to_a }
        stats_array.size > 1 ? stats_array : stats_array.flatten
      end

      StatsForAll::CONFIGURATION["types"].each do |type, value|

        define_method( :"#{type.pluralize}") do |*args|
          args=args.first
          args ||= {} 
          raise(ArgumentError, "wrong number of arguments 3 is the maximum.") if args.size > 3
          args.merge! :type => value
          self.stat( args )
        end 
        
        define_method(:"add_#{type}") do
          self.save_stats(value)
        end         
      end

      # use with params like Stat::TYPE[:click]
      def save_stats(type, hour=Time.now.hour)
        case StatsForAll::CONFIGURATION["increment_type"]
          when "direct"
            direct_save(type, hour)
          when "starling"
            starling_save(type, hour)
          when "drb"
            drb_save(type, hour)
          else
            false
        end
      end 
      
      private
      # use with params like Stat::TYPE[:click]
      def load_stats(type)
        (self.stats.today.stats_type(type).first or self.stats.create(:stat_type => type)).id
      end
      
      def direct_save(type, hour=Time.now.hour)
        stat=Stat.find(load_stats(type)) or raise ActiveRecord::RecordNotFound
        stats_array=stat.to_a
        stats_array[hour] += 1
        stat.data=Marshal.dump(stats_array)
        stat.save
        stat.update_all_stats
      end
      
      def starling_save(type, hour=Time.now.hour)
        self.push("drb_save", type, hour)
      end
      
      def drb_save(type, hour=Time.now.hour)
        DRb.start_service
        stats_server = DRbObject.new(nil, "druby://#{StatsForAll::CONFIGURATION["server_host"]}:#{StatsForAll::CONFIGURATION["server_port"]}")
        value=stats_server.increment(load_stats(type), Time.now.hour)                
        DRb.stop_service
        value
      end

    end

  end    
end