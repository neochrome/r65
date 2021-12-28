require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

bitmap = Loaders::Bitmap::MultiColor.from_file "./bitmap_m.png"

vic2 = VIC2::Config.new.bitmap_at(0x2000)

cfg = SegmentConfig.new do |cfg|
  cfg.define :code, start: 0x801
  cfg.define :bitmap, start: vic2.bitmap
end

prg = Program.new cfg do
  segment! :code

  call Macros::Bootstrap do
    call vic2.init
    # enable bitmap
    lda VIC2::Control1::Register
    ora &VIC2::Control1::Bitmap
    sta VIC2::Control1::Register
    # enable multicolor
    lda VIC2::Control2::Register
    ora &VIC2::Control2::Multicolor
    sta VIC2::Control2::Register

    lda &bitmap.background_color
    sta VIC2::BackgroundColor

    call Macros::Utils::LoadScreen,
      screen_data: :screen_data,
      screen: vic2.screen,
      color_data: :color_data,
      color: vic2.color

    label :loop
    jmp :loop
  end

  segment :bitmap do
    byte bitmap.data
    label :screen_data do
      byte bitmap.screen
    end
    label :color_data do
      byte bitmap.color
    end
  end
end

prg.write
