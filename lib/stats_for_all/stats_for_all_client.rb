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
      
      # Cool syntax stats retrieve supported!, like:
      # @object.stat :type=> Stat::TYPE[:click], :day => 21..24, :month =>10..12, :year => 2007..2009
      # @object.stat :type=> Stat::TYPE[:click], :day => 21, :month =>10, :year => 2008
      # @object.stat :type=> Stat::TYPE[:click], :month =>10, :year => 2008
      # @object.stat :type=> Stat::TYPE[:click], :year => 2008

      def stat(arg={})
        raise(ArgumentError, "type is a mandatory argument") unless arg[:type]          
        stats_array= stats.day(arg[:day]).month(arg[:month]).year(arg[:year]).stats_type(arg[:type]).map { |stat| stat.to_a }
        stats_array.size > 1 ? stats_array : stats_array.flatten
      end

      # use it with params like Stat::TYPE[:click]
      # dispatcher to increment the stats, will call the method defined in the configuration file, 
      # you can use it directly with the type or use one of the wrapper defined 

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
            
      # With this metaprogram piece of code. We generate two methods for each type defined in the configuration file,
      # they are wrapper for the "stat" and "save_stat" methods containing itself the type in the call.
      # for example: with the type defined like [click: 0] the code will generate the "clicks" method to get the clicks and "add_click" to incremente de stats.

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
      
      # @bject.multi_stats(:year => 2008, :month => 10, :day => 29, :type => ["hit", "click"])
      # or @object.multi_stats(@object.available_days.group_by_types[0])
      # => {"hit"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0],
      #     "click"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0]}

      def multi_stats(arg={})
        raise(ArgumentError, "wrong number of arguments 1 is the minimun.") if arg.size == 0
        raise(ArgumentError, ":type must be an array of types") unless arg[:type]
        arg.to_yaml
        stats_hash={}
        arg[:type].each do |type|
          my_stats=stats.day(arg[:day]).month(arg[:month]).year(arg[:year]).stats_type(StatsForAll::CONFIGURATION["types"][type])
          stats_hash.merge!(Hash[type, []]) if my_stats.instance_of?(Array)
          my_stats.each do |stat| 
            stats_hash.merge!(Hash[type, stat.to_a])
          end
        end
        stats_hash
      end

      # Method prepared to retrieve easily all the stats data stored      
      #
      # @object.available_days("click") or 
      # @object.available_days
      # =>[ {:type=>["click"], :day=>20, :month=>10, :year=>2008}, 
      #    {:type=>["hit"], :day=>20, :month=>10, :year=>2008},
      #    {:type=>["hit"], :day=>21, :month=>10, :year=>2008} ]
      #
      # Using the array method group_by_types
      # @object.available_days  :group => true
      # => [{:type=>["click", "hit"], :day=>29, :month=>10, :year=>2008}, {:type=>["hit"], :day=>30, :month=>10, :year=>2008}]
      #
      # You can use some optional params like:
      # ":group => true" to group by type the stats, a more compact way to retrieve the stats
      # ":direct => true" to get directly the data stats arrays
      # ":month => 10, :year => 2008" to specify directly more concrects dates
      # @object.available_days :group => true, :direct => true, :month => 10, :year => 2008

      def available_days(arg={})
        st=arg[:type] ? stats.days_only.type_only(arg[:type]) : stats.days_only
        st=st.year(arg[:year]) if arg[:year]
        st=st.month(arg[:month]) if arg[:month]
        prepare_stat_data(st, arg)
      end

      # Method prepared to retrieve easily all the stats data stored
      #
      # @object.available_monhts("click") or 
      # @object.available_monhts
      # =>[ {:type=>["click"], :day=>0, :month=>10, :year=>2008}, 
      #    {:type=>["hit"], :day=>0, :month=>10, :year=>2008},
      #    {:type=>["hit"], :day=>0, :month=>10, :year=>2008} ]
      #
      # using the array method group_by_types
      # @object.available_monhts :group => true
      # => [{:type=>["click", "hit"], :day=>0, :month=>10, :year=>2008}, {:type=>["hit"], :day=>0, :month=>11, :year=>2008}]
      #
      # You can use some optional params like:
      # ":group => true" to group by type the stats, a more compact way to retrieve the stats
      # ":direct => true" to get directly the data stats arrays
      # ":year => 2008" to specify directly more concrects dates
      # @object.available_days :group => true, :direct => true, :year => 2008

      def available_months(arg={})
        st=arg[:type] ? stats.months_only.type_only(arg[:type]) : stats.months_only
        st=st.year(arg[:year]) if arg[:year]
        prepare_stat_data(st, arg)
      end
      
      # Method prepared to retrieve easily all the stats data stored
      #
      # @object.available_years("click") or 
      # @object.available_years
      # =>[ {:type=>["click"], :day=>0, :month=>0, :year=>2008}, 
      #    {:type=>["hit"], :day=>0, :month=>0, :year=>2008},
      #    {:type=>["hit"], :day=>0, :month=>0, :year=>2008} ]
      #
      # using the array method group_by_types
      # @object.available_years  :group => true
      # => [{:type=>["click", "hit"], :day=>0, :month=>0, :year=>2008}, {:type=>["hit"], :day=>0, :month=>0, :year=>2009}]
      #
      # You can use some optional params like:
      # ":group => true" to group by type the stats, a more compact way to retrieve the stats
      # ":direct => true" to get directly the data stats arrays
      # @object.available_days :group => true, :direct => true
      
      def available_years(arg={})
        st=arg[:type] ? stats.years_only.type_only(arg[:type]) : stats.years_only
        prepare_stat_data(st, arg)
      end
      
      private
      
      # this method prepare the output format of the available_* methods.
      def prepare_stat_data(st, arg)
        hashes=st.map do |stat| 
          Hash[ :day, stat.day, :month, stat.month, :year , stat.year, :type, [stat.type]] 
        end    
        hashes = hashes.group_by_types if arg[:group]
        hashes = hashes.map { |h| multi_stats h } if arg[:direct]
        return hashes
      end
      
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
        stats_server = DRbObject.new(nil, "druby://#{StatsForAll::CONFIGURATION["server_host"]}:#{StatsForAll::CONFIGURATION["server_port"]}")
        value=stats_server.increment(load_stats(type), Time.now.hour)                
        DRb.stop_service
        value
      end

    end

  end    
end