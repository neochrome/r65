module RangeExtensions

  def intersect? (other)
    self.include? other.min or self.include? other.max or other.include? self.min or other.include? self.max
  end

end
