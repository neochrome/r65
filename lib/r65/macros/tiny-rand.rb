module R65
	module Macros
		TinyRand = proc do
			label :tiny_rand do
				# from: https://codebase64.org/doku.php?id=base:ax_tinyrand8
				#
				# AX+ Tinyrand8
				# A fast 8-bit random generator with an internal 16bit state
				#
				# Algorithm, implementation and evaluation by Wil
				# This version stores the seed as arguments and uses self-modifying code
				# The name AX+ comes from the ASL, XOR and addition operation
				#
				# Size: 15 Bytes (not counting the set_seed function)
				# Execution time: 18 (without RTS)
				# Period 59748

				# the next random byte will be available in A after calling
				label :byte
				label :b #b=*+1
				lda &31
				asl
				label :a #a=*+1
				eor &53
				sta :b+1
				adc :a+1
				sta :a+1
				rts


				# sets the seed based on the value in A
				# always sets a1 and b1 so that a cycle with maximum period is chosen
				# constants 217 and 21263 have been derived by simulation
				label :init
				pha
				ana &217
				clc
				adc &21263.lo_b # <
				sta :a+1
				pla
				ana &255-217
				adc &21263.hi_b # >
				sta :b+1
				rts
			end

		end
	end
end
