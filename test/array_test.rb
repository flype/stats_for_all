require File.expand_path(File.dirname(__FILE__) + '/stats_for_all_test_helper') 

class ArrayTest < Test::Unit::TestCase
  
  def test_should_add_arrays_correctly
    a = [1,1,1]
    assert_equal a.add([1,1,1]), [2,2,2]
    assert_equal a.add([2,2,2]), [3,3,3]
    assert_equal a.add([1,2,3]), [2,3,4]
    
    assert_raise ArgumentError do
      a.add([1,2,3,4])
    end
    
    assert_raise ArgumentError do
      [1,2,3,4].add(a)
    end
  end


  def test_should_check_that_group_by_types_is_working
    a = [{:type=>["click"], :day=>29, :month=>10, :year=>2008},
       {:type=>["hit"], :day=>29, :month=>10, :year=>2008},
       {:type=>["hit"], :day=>30, :month=>10, :year=>2008}]

    b = [{:type=>["click", "hit"], :day=>29, :month=>10, :year=>2008}, 
       {:type=>["hit"], :day=>30, :month=>10, :year=>2008}]

    assert_equal a.group_by_types, b

    a = [{:type=>["click"], :day=>29, :month=>10, :year=>2008},
       {:type=>["hit"], :day=>29, :month=>10, :year=>2008},
       {:type=>["hit"], :day=>30, :month=>10, :year=>2008},
       {:type=>["click"], :day=>30, :month=>10, :year=>2008},
       {:type=>["hit"], :day=>27, :month=>8, :year=>2007},
       {:type=>["click"], :day=>27, :month=>8, :year=>2007}]

    b = [{:type=>["click", "hit"], :day=>29, :month=>10, :year=>2008}, 
       {:type=>["hit", "click"], :day=>30, :month=>10, :year=>2008},
       {:type=>["hit", "click"], :day=>27, :month=>8, :year=>2007}]

    assert_equal a.group_by_types, b
    
  end

end
