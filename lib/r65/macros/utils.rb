module R65
  module Macros
    module Utils

      PushState = proc do |address:|
        sta address+1
        stx address+3
        sty address+5
      end

      PopState = proc do
        lda &0
        ldx &0
        ldy &0
      end

      WasteCycles = proc do |cycles:|
        raise RangeError, "Cycles must be 2 or more" unless cycles > 1
        nops = cycles / 2
        rem = cycles & 1
        (nops - rem).times do
          nop
          cycles -= 2
        end
        if rem == 1
          bit 0xfe,:z
          cycles -= 3
        end
        raise "Cycles left: #{cycles}, should be 0" unless cycles == 0
      end

    end
  end
end
