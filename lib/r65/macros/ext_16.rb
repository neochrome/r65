module R65
	module Macros
		module Ext16

			SetImmediate = proc do |address:, value:|
				lda &value.lo_b
				sta address
				lda &value.hi_b
				sta address+1
			end

      Copy = proc do |target:, source:|
        lda source.lo_b
        sta target
        lda source.hi_b
        sta target+1
      end

      AddImmediate = proc do |address:, value:|
        clc
        lda address
        adc &value.lo_b
        sta address
        lda address+1
        adc &value.hi_b
        sta address+1
      end

      Add = proc do |address:, value:|
        clc
        lda address
        adc value.lo_b
        sta address
        lda address+1
        adc value.hi_b
        sta address+1
      end

      SubImmediate = proc do |address:, value:|
        sec
        lda address
        sbc &value.lo_b
        sta address
        lda address+1
        sbc &value.hi_b
        sta address+1
      end

      Sub = proc do |address:, value:|
        sec
        lda address
        sbc value.lo_b
        sta address
        lda address+1
        sbc value.hi_b
        sta address+1
      end

      Increment = proc do |address:|
        call AddImmediate, address:address, value: 1
      end

      Decrement = proc do |address:|
        call SubImmediate, address:address, value: 1
      end

		end
	end
end
