require File.expand_path(File.dirname(__FILE__) + '/stats_for_all_test_helper') 

class BannerTest < Test::Unit::TestCase
  
  def setup
    setup_db
  end
  
  context "A stats_for_all_client" do
    setup do
      @data=Array.new(24,0)
      @art=Factory(:banner)
      @stat1=Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year )
    end

    should_have_many :stats
    should_have_instance_methods  :add_click, :add_hit, :hits, :clicks, :save_stats, :stat
    
    should "work with the direct mode" do
      assert_equal "direct", StatsForAll::CONFIGURATION["increment_type"]
      assert @art.add_click
      assert_equal 1, @art.clicks.sum
      assert @art.add_click
      assert @art.add_click
      assert @art.add_click
      assert_equal 4, @art.clicks.sum

      assert_equal 24, @art.clicks(:day => Time.now.day, :month => Time.now.month, :year => Time.now.year).size
      assert_equal 4, @art.clicks(:day => Time.now.day, :month => Time.now.month, :year => Time.now.year).sum

      assert_equal Time.days_in_month(Time.now.month), @art.clicks(:month => Time.now.month, :year => Time.now.year).size
      assert_equal 4, @art.clicks( :month => Time.now.month, :year => Time.now.year).sum

      assert_equal 12, @art.clicks(:year => Time.now.year).size
      assert_equal 4, @art.clicks( :year => Time.now.year).sum      
      
      assert_equal 12, @art.clicks.size      
    end
    
    context "A banner with a day of stats" do
      setup do
        @data=Array.new(24,0)
        @day=4
        5.times do
          @data[@day]=10
          @day+=1
        end
        @art=Factory(:banner)
        @stat1=Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year )
        @stat1.update_all_stats
      end

      should "return some correct stats" do
        assert_equal 24, @art.stat( :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year, :type =>1).size
        assert_equal Time.days_in_month(Time.now.month), @art.stat( :month=> Time.now.month, :year => Time.now.year, :type =>1).size
        assert_equal 12, @art.stat( :type =>1).size

        assert_equal 10, @art.stat( :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year, :type =>1)[@day-1]
        assert_equal 50, @art.stat( :month=> Time.now.month, :year => Time.now.year, :type =>1)[Time.now.day-1]
        assert_equal 50, @art.stat( :type =>1)[Time.now.month-1]
      end
    end
    
    context "A banner" do
      setup do
        @art1=Factory(:banner)
        @art1.add_click
        @art1.add_hit
                
        # @art1.stats.each {|a| a.update_all_stats }
        
        @art2=Factory(:banner)               
        @art2.add_hit
        @art2_result=[{:type=>["hit"], :day=>Time.now.day, :month=>Time.now.month, :year=>Time.now.year}]
        @art2.stats.first.update_all_stats
        
        StatsForAll::CONFIGURATION["increment_type"]="direct"

      end

      should "have the correct available months, days and years in the correct format" do
        assert_equal 2, @art1.available_days.size 
        assert_equal 2, @art1.available_years.size
        assert_equal 2, @art1.available_months.size 

        assert_equal 1, @art1.available_days.group_by_types.size 
        assert_equal 1, @art1.available_years.group_by_types.size 
        assert_equal 1, @art1.available_months.group_by_types.size 
        
        assert_equal 1, @art2.available_days.size 
        assert_equal 1, @art2.available_months.size 
        assert_equal 1, @art2.available_years.size 
    
        assert_equal @art2_result, @art2.available_days
      end
      
      should "be able to get the data arrays from the multi_stats method" do
        assert_equal 1, @art2.available_days(:direct => true, :group => true).size
        assert_equal 2, @art1.available_days(:direct => true).size
      end
    end
    

    context "A banner with some days of stats" do
      setup do
        @data=Array.new(24,0)
        @day=4
        5.times do
          @data[@day]=10
          @day+=1
        end
        @art=Factory(:banner)
        @stat1=Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year )
        @stat1.update_all_stats
        @stat2=Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> (Time.now.day+1), :month=> Time.now.month, :year => Time.now.year )
        @stat2.update_all_stats
      end

      should "return some correct stats" do
        assert_equal 2, @art.stat( :day=> Time.now.day..Time.now.day+1, :month=> Time.now.month, :year => Time.now.year, :type =>1).size
        assert_equal 100, @art.stat( :day=> Time.now.day..Time.now.day+1, :month=> Time.now.month, :year => Time.now.year, :type =>1).flatten.sum
        assert_equal 10, @art.stat( :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year, :type =>1)[@day-1]
        assert_equal 50, @art.stat( :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year, :type =>1).sum
        assert_equal 50, @art.stat( :month=> Time.now.month, :year => Time.now.year, :type =>1)[Time.now.day-1]
        assert_equal 100, @art.stat( :month=> Time.now.month, :year => Time.now.year, :type =>1).sum
        assert_equal 100, @art.stat( :type =>1)[Time.now.month-1]
      end
    end
    
    should "work with the drb mode" do
      StatsForAll::CONFIGURATION["increment_type"]="drb"
      assert_equal "drb", StatsForAll::CONFIGURATION["increment_type"]

      assert system("cd ../../../; export RAILS_ENV='test'; rake stats_for_all:start; cd vendor/plugins/stats_for_all")

      assert @art.add_hit
      
      sleep (StatsForAll::CONFIGURATION["dump_frequency_in_seconds"] + 2)

      assert_equal 1, @art.hits.sum
      assert @art.add_hit
      assert @art.add_hit
      assert @art.add_hit
      
      sleep (StatsForAll::CONFIGURATION["dump_frequency_in_seconds"] + 2)
      
      assert_equal 4, @art.hits.sum

      assert_equal 24, @art.hits(:day => Time.now.day, :month => Time.now.month, :year => Time.now.year).size
      assert_equal 4, @art.hits(:day => Time.now.day, :month => Time.now.month, :year => Time.now.year).sum

      assert_equal Time.days_in_month(Time.now.month), @art.hits(:month => Time.now.month, :year => Time.now.year).size
      assert_equal 4, @art.hits( :month => Time.now.month, :year => Time.now.year).sum

      assert_equal 12, @art.hits(:year => Time.now.year).size
      assert_equal 4, @art.hits( :year => Time.now.year).sum      
      
      assert system("cd ../../../; export RAILS_ENV='test'; rake stats_for_all:stop ; cd vendor/plugins/stats_for_all")
    end
    
    # this test is prepared for the future  simplified_starling gem
    # should "work with the starling mode" do
    #   StatsForAll::CONFIGURATION["increment_type"]="starling"
    #     assert_equal "starling", StatsForAll::CONFIGURATION["increment_type"]
    #         
    #     assert system("cd ../../../; export RAILS_ENV='test'; rake simplified_starling:start_and_process_jobs; cd vendor/plugins/stats_for_all")
    #     assert system("cd ../../../; export RAILS_ENV='test'; rake stats_for_all:start; cd vendor/plugins/stats_for_all")
    #         
    #     assert @art.add_hit
    #     
    #     sleep (StatsForAll::CONFIGURATION["dump_frequency_in_seconds"] + 2)
    #         
    #     assert_equal 1, @art.hits.sum
    #     assert @art.add_hit
    #     assert @art.add_hit
    #     assert @art.add_hit
    #     
    #     sleep (StatsForAll::CONFIGURATION["dump_frequency_in_seconds"] + 2)
    #     
    #     assert_equal 4, @art.hits.sum
    #         
    #     assert_equal 24, @art.hits(:day => Time.now.day, :month => Time.now.month, :year => Time.now.year).size
    #     assert_equal 4, @art.hits(:day => Time.now.day, :month => Time.now.month, :year => Time.now.year).sum
    #         
    #     assert_equal 31, @art.hits(:month => Time.now.month, :year => Time.now.year).size
    #     assert_equal 4, @art.hits( :month => Time.now.month, :year => Time.now.year).sum
    #         
    #     assert_equal 12, @art.hits(:year => Time.now.year).size
    #     assert_equal 4, @art.hits( :year => Time.now.year).sum      
    #   
    #   assert system("cd ../../../; export RAILS_ENV='test'; rake simplified_starling:stop_processing_jobs  ; cd vendor/plugins/stats_for_all")      
    #   assert system("cd ../../../; export RAILS_ENV='test'; rake stats_for_all:stop ; cd vendor/plugins/stats_for_all")
    #   assert system("cd ../../../; export RAILS_ENV='test'; rake simplified_starling:stop  ; cd vendor/plugins/stats_for_all")      
    # end

    
  end
end
teardown_db