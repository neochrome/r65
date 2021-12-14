require_relative "../lib/r65"

include R65

# Sets up named segments, which may be used to
# organize instructions into predictable groupings
cfg = SegmentConfig.new do |cfg|
  cfg.define :code, start: 0x0000 # the first segment will be used by default
  cfg.define :data, start: 0x0200
end

prg = Program.new cfg do
  # Regular instructions

  ## Non-indexed, non-memory
  lsr            # accumulator
  lda &0x42      # immidiate
  clc            # implied / none

  ## Non-indexed
  bne -0x02      # relative back (only branching)
  bne 0x02       # relative forward (only branching)
  jmp 0x1234     # absolute
  lda 0x12,:z    # absolute, zero-page
  jmp [0x1234]   # indirect (only jmp)

  ## Indexed
  lda 0x1001,:x  # absolute, x-indexed
  lda 0x1002,:y  # absolute, y-indexed
  lda 0x11,:zx   # zero-page, x-indexed
  ldx 0x12,:zy   # zero page, y-indexed
  lda [0x13],:x  # indirect, x-indexed
  lda [0x14],:y  # indirect, y-indexed

  ## Some addressing math
  lda 1+:foo             # constant + label
  lda :foo+1             # label + constant
  lda :foo+:bar          # label + label
  lda :foo.lo_b          # low byte of label address
  lda :foo.hi_b          # high byte of label address
  lda &:foo.hi_b         # high byte of label address, as immidiate value


  # Pseudo instructions

  byte 0xee              # simple byte
  word 0x1234            # word as two bytes, LE - order
  align! 8               # align to next 8 (power of two) address
  byte (0x00..0x15).to_a # array of bytes
  fill 4, 0x04           # shortcut to fill out n bytes as specified
  pc! 0x0054             # sets the program counter to the specified address..
                         # ..and fills the resulting gaps with zeroes

  label :foo             # a regular label
  label :bar do          # a label..
    jmp :foo             # ..with a..
  end                    # ..block scope

  scope :scoped do       # introduces an explicit naming scope..
    label :foo           # ..where labels shadows those from the outer scope
    byte 0x00
  end
  jmp :"scoped:foo"      # it's possible to refer to scoped/nested label by full name


  # Macros

  # Macros are plain ruby procs which may have arguments,
  # even nested blocks are possible.
  # By default macros don't introduce a new scope, but it's
  # possible to do so either by defining a scope using the
  # label or scope pseudo instructions, or when calling the
  # macro.
  AMacro = proc do |arg1:, block:nil|
    byte arg1
    call block unless block.nil?
  end

  call AMacro, arg1: 0x42               # calls a macro with argument(s)
  call_with_scope AMacro, arg1: 0x42 do # call a macro with an implicit scope..
    label :foo                          # ..to avoid name conflicts
    byte 0xff
  end


  # Segments

  segment :data do                 # switch to the specified segment..
    fill 16, 0xff                  # ..for the duration of the block..
    label :foo                     # ..also an implicit scope is created
  end
  segment :data, in_scope: true do # it's also possible to switch segment..
    label :some_data               # ..without an implicit scope
    byte 0x01
  end
  lda :some_data
  segment! :data                   # finally, a segment may be specified for..
  byte 0xab                        # ..all following instructions

end

prg.write
