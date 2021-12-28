require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

prg = Program.new do

  line = proc do |color|
    lda &color
    sta VIC2::BorderColor
    sta VIC2::BackgroundColor
    ldx VIC2::RasterCounter
    label :wait do
      cpx VIC2::RasterCounter
      beq :wait
    end
  end

  chain = C64::Macros::IRQ::Raster::Chain.new

  chain.exactly_at line: 190 do
    [14,6].each do |color|
      call_with_scope line, color, scope: color.to_s
    end
  end

  chain.exactly_at line: 206 do
    [14,0].each do |color|
      call_with_scope line, color
    end
  end

  call Macros::Bootstrap do
    sei

    lda &ROMConfig::NoKernal
    sta ROMConfig::ControlRegister

    call Macros::IRQ::Timers::Disable
    call Macros::IRQ::Timers::Cancel

    call Macros::IRQ::Raster::Enable
    call chain.start

    cli
  end

  label :main do
    jmp :main
  end

  call chain.init

end

prg.write
