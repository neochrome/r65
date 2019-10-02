module BytesExtensions

  def word (offset)
    self[offset] + (self[offset + 1] << 8)
  end

  def word_be (offset)
    (self[offset] << 8) + self[offset + 1]
  end

end
