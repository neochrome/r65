module C64
  module Macros

      Bootstrap = proc do |start = nil, block|
        basic = 0x0801
        raise ArgumentError, "Can't supply both start address and block at the same time." if start and block
        start = basic + 13 unless start
        pc! basic                  # [0] start of basic program
        word 0x080c                # [2] next basic line
        word 0x000a                # [2] basic line number 10
        byte 0x9e                  # [1] sys
        byte start.to_s.to_scr     # [4-5] address in decimal screencodes
        byte 0x00                  # [1] basic <eol>
        word 0x0000                # [2] end of basic program
        byte 0x00 if start < 10000 # [1-0] padding
        call block if block        # total: 13 bytes
      end

  end
end
