require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

bitmap = Loaders::Bitmap::Standard.from_file "./bitmap_s.png"

vic2 = VIC2::Config.new.bitmap_at(0x2000)

cfg = SegmentConfig.new do |cfg|
  cfg.define :code, start: 0x801
  cfg.define :bitmap, start: vic2.bitmap
end

prg = Program.new cfg do
  segment! :code

  call Macros::Bootstrap do
    call vic2.mem_setup
    # enable bitmap
    lda VIC2::Control1::Register
    ora &VIC2::Control1::Bitmap
    sta VIC2::Control1::Register

    call Macros::Utils::LoadScreen,
      screen_data: :screen_data,
      screen: vic2.screen

    label :loop
    jmp :loop
  end

  segment :bitmap, in_scope: true do
    byte bitmap.data
    label :screen_data do
      byte bitmap.screen
    end
  end
end

prg.write
