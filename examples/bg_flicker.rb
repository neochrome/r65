require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

prg = Program.new do
  call Macros::Bootstrap do
    label :loop do
      inc VIC2::BackgroundColor
      jmp :loop
    end
  end
end

prg.run
