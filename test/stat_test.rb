require File.expand_path(File.dirname(__FILE__) + '/stats_for_all_test_helper') 

class StatTest < Test::Unit::TestCase
  
  def setup
    setup_db
  end
  
  context "A Stat" do
    setup do                    
      @art = Factory(:banner)
      @stat = Factory(:stat, :model_id => @art.id)      
    end

    should "UnMarshal correctly the array" do
      assert_equal Array.new(24,0), @stat.to_a
    end
  end
      
  context "some Stat" do
    setup do
      @data = Array.new(24,0)
      day = 4
      5.times do
        @data[day] = 10
        day += 1
      end
      @art = Factory(:banner)
      @stat1 = Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> Time.now.day, :month=> Time.now.month, :year => Time.now.year )
      @stat2 = Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> (Time.now.day+1), :month=> Time.now.month, :year => Time.now.year )
    end

    should "prepare correctly the daily and monthly stat" do
      # assert_equal @stat1.update_day, Stat.month_only.only(@stat1).first.to_a
      assert_equal 50, @stat1.update_day[Time.now.day-1]
      assert_equal 50, @stat1.update_month[Time.now.month-1]

      assert @stat2.update_all_stats
      assert_equal 100, @art.stats.stats_type(1).month_only.first.to_a.sum
      assert_equal 100, @art.stats.stats_type(1).year_only.first.to_a.sum
    end
  end


  context "Some stats" do
    setup do
      @data = Array.new(24,0)
      day = 4
      5.times do
        @data[day]= 10
        day += 1
      end
      @art = Factory(:banner)
      @stat1 = Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> Time.now.day,:month=> Time.now.month, :year => Time.now.year )
      @stat2 = Factory(:stat, :model_id => @art.id, :data => Marshal.dump(@data), :day=> (Time.now.day - 1 ), :month=> Time.now.month, :year => Time.now.year   )      
    end

    should "update the days and month array" do
      assert_equal 2, Stat.count(:all)
      assert_equal 50, @stat1.update_day[(Time.now.day-1)]
      assert_equal 50, @stat2.update_day[(Time.now.day-2)]
      
      assert_equal 3, Stat.count(:all)
      assert_equal 100, @stat1.update_month[(Time.now.month-1)]
      assert_equal 100, @stat2.update_month[(Time.now.month-1)]
      
    end
    
    should "access the model from the stats" do
      assert_equal @art, @stat1.model      
    end
  end
  
  
end

teardown_db