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

      assert_equal 31, @art.clicks(:month => Time.now.month, :year => Time.now.year).size
      assert_equal 4, @art.clicks( :month => Time.now.month, :year => Time.now.year).sum

      assert_equal 12, @art.clicks(:year => Time.now.year).size
      assert_equal 4, @art.clicks( :year => Time.now.year).sum      
      
      assert_equal 12, @art.clicks.size
      
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

      assert_equal 31, @art.hits(:month => Time.now.month, :year => Time.now.year).size
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