require File.expand_path(File.dirname(__FILE__) + '/stats_for_all_test_helper') 

class ArrayTest < Test::Unit::TestCase
  
  def test_should_add_arrays_correctly
    a=[1,1,1]
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

end
