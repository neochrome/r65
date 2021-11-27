require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

music = Loaders::Sid.from_file "./music.sid"

segs = SegmentConfig.new do |cfg|
  cfg.define :code, start: 0x801
  cfg.define :music, start: music.start
end

prg = Program.new segs do
  segment :music do
    byte music.data
  end

  segment! :code
  call Macros::Bootstrap do
    sei

    lda &ROMConfig::NoKernal
    sta ROMConfig::ControlRegister

    call Macros::IRQ::Timers::Disable
    call Macros::IRQ::Timers::Cancel

    call Macros::IRQ::Raster::Enable
    call Macros::IRQ::Raster::Install, address: :play, line: 0

    lda &0
    jsr music.init

    cli
  end

  label :main do
    jmp :main
  end

  label :play do
    call Macros::IRQ::Raster::Handler do
      call Macros::Utils::DebugRaster, 1
      jsr music.play
      call Macros::Utils::DebugRaster, 0
    end
  end

end

prg.write
