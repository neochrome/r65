require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

sprites = Loaders::Spritemate.from_file "./sprites.spm"
circle = sprites["circle"]

vic2 = VIC2::Config.new.bank_at(0x0000)

cfg = SegmentConfig.new do |cfg|
  cfg.define :code, start: 0x801
  cfg.define :data, start: vic2.bank + 0x2000
end

prg = Program.new cfg do
  segment! :code

  call Macros::Bootstrap do
    call vic2.init

    lda &0x00
    sta VIC2::Sprite::DoubleWidthRegister
    sta VIC2::Sprite::DoubleHeightRegister
    lda &0xff
    sta VIC2::Sprite::MulticolorRegister
    sta VIC2::Sprite::EnableRegister
    lda &circle.multicolor1
    sta VIC2::Sprite::Multicolor1
    lda &circle.multicolor2
    sta VIC2::Sprite::Multicolor2

    8.times do |i|
      lda &vic2.sprite_data(:sprite_data, i)
      sta vic2.sprite_pointer(i)
      ldx &(32*(i % 4 + 2))
      stx vic2.sprite_x(i)
      ldy &(32*(i / 4 + 2))
      sty vic2.sprite_y(i)
      lda &circle.frames[i].color
      sta vic2.sprite_color(i)
    end

    rti
  end

  segment :data do
    align! 64
    label :sprite_data
    circle.frames.each do |frame|
      byte frame.data
    end
  end

end

prg.write
