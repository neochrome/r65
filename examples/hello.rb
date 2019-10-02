require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

prg = Program.new do
  call Macros::Bootstrap do
    ldx &0
    label :loop do
      lda :msg,:x
      cmp &"#".to_scr.first
      beq :done
      sta VIC2::DefaultScreen,:x
      inx
      jmp :loop
    end
    label :done
    rti
  end

  label :msg
  byte "HELLO WORLD!#".to_scr
end

prg.run
