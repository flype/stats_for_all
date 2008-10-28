class Array
  def add(a)
    raise(ArgumentError, "the two arrays must have the same size") if self.size != a.size
    (0..a.size-1).map do |i| 
      self[i] + a[i]
    end    
  end
end