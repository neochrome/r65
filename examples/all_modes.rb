require_relative "../lib/r65"

include R65

all_modes = Program.new do
  label :foo
  lda &1
  label :bar
  lda 2
  label :baz
  jmp 3
  label :buz
  jmp [4]
  label :biz
  lda 5,:x
  lda [6],:y
  lda :foo
  jmp [:bar]
  lda 0x10,:zx
  lda [0x10],:zy
  byte (0..15).to_a
  word 0x1234
  bne -7
  bne 8
  bne :biz
  lda 2222
  jmp 3333
  jmp [4444]
  lda 5555,:y
  asl
  # some addressing math
  lda :foo
  lda 1+:foo
  lda :foo+1
  lda &:foo.lo_b
  lda &:foo.hi_b
end

puts all_modes
