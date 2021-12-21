module C64

  class ZeroPage
    attr_reader :pc

    @unsafe = [
      0x00..0x01
    ]

    def initialize()
      @pc = 0x02
      @labels = {}
    end

    def any?
      @labels.any?
    end

    def has? (label)
      @labels.has_key?(label)
    end

    def [] (label)
      raise KeyError, "Label #{label} not registered" unless has? label
      @labels[label]
    end

    def bytes (label, count)
      raise KeyError, "Label #{label} already registered" if has? label
      raise RangeError, " %d byte(s) does not fit between %02x and 0xff" % [count,@pc] if @pc + count > 0xff
      @labels[label] = @pc
      @pc += count
      self
    end

    def byte (label)
      bytes label, 1
    end

    def word (label)
      bytes label, 2
    end

    def to_s
      @labels.to_s
    end

  end

end
