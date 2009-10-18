class Array
  def add(a)
    raise(ArgumentError, "the two arrays must have the same size") if self.size != a.size
    (0..a.size-1).map {|i| self[i] + a[i] }
  end

  # used to merge all the types in one row
  # I think need some refactor
  def group_by_types
    array, final_array = [], [];
    
    self.each do |i|
       array << self.map { |j| j if i[:day] == j[:day] and i[:month] == j[:month] and i[:year] == j[:year] }.compact.map {|s| s[:type] }.flatten
    end
    
    i = 0;
    self.map do |j| 
      j[:type] = array[i]
      found_final_array = false
      final_array.each { |a| found_final_array = true if a == j }
      final_array << j unless found_final_array
      i+= 1
    end
    final_array
  end
end