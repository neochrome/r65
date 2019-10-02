module IntegerExtensions

  def twos_complement
    self & 0xff # TODO: this must be wrong!?
  end

  def power_of_two?
    self > 0 and (self & (self - 1)).zero?
  end

  def divisible_by? (num)
    (self % num).zero?
  end

end
