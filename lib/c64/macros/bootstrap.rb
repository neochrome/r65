module C64
  module Macros

      Bootstrap = proc do |block:|
        raise ArgumentError, "Must supply a block." unless block.is_a? Proc
        start = DefaultBasic::Start + 13 # start 13 bytes after basic
        pc! DefaultBasic::Start          # [0] start of basic program
        word 0x080c                      # [2] next basic line
        word 0x000a                      # [2] basic line number 10
        byte 0x9e                        # [1] sys
        byte start.to_s.to_scr           # [4-5] address in decimal screencodes
        byte 0x00                        # [1] basic <eol>
        word 0x0000                      # [2] end of basic program
        byte 0x00 if start < 10000       # [1-0] padding
        call block                       # total: 13 bytes
      end

  end
end
