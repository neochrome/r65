require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

top = { address: :top, line: 190 }
bottom = { address: :bottom, line: 206 }

prg = Program.new do
  call Macros::Bootstrap do
    sei

    lda &ROMConfig::NoKernal
    sta ROMConfig::ControlRegister

    call Macros::IRQ::Timers::Disable
    call Macros::IRQ::Timers::Cancel

    call Macros::IRQ::Raster::Enable
    call Macros::IRQ::Raster::Install, top

    cli
  end

  label :main do
    jmp :main
  end

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

  label :top do
    call Macros::IRQ::Raster::StableHandler, bottom do
      [14,6].each do |color|
        call line, color
      end
    end
  end

  label :bottom do
    call Macros::IRQ::Raster::StableHandler, top do
      [14,0].each do |color|
        call line, color
      end
    end
  end

end

puts prg.to_s
prg.run
