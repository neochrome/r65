require_relative "../lib/r65"
require_relative "../lib/c64"

include R65
include C64

bmp = Loaders::Bitmap::SingleColor.from_file "./font.png"
# bmp.invert!
font = Loaders::Font.new(
  bmp,
  width: 2,
  height: 2,
  charmap: " ABCDEFGHIJKLMNOPQRSTUVWXYZ01234",
)

vic2 = VIC2::Config.new.bank_at(0x4000).char_at(0x0800)

cfg = SegmentConfig.new do |cfg|
  cfg.define :code, start: 0x801
  cfg.define :charset, start: vic2.char
end

prg = Program.new cfg do
  call Macros::Bootstrap do
    call vic2.init

    # "clear" screen
    ldx &0
    label :copy do
      [0x000, 0x100, 0x200, 0x2e8].each do |o|
        lda &0
        sta vic2.screen+o,:x
      end
      inx
      bne :copy
    end

    g = font["A"]
    g.height.times do |y|
      g.width.times do |x|
        lda &g[x,y]
        sta vic2.screen+(y*40)+x
      end
    end

    ldx &0
    label :loop do
      txa
      4.times do |y|
        sta vic2.screen+(10+y)*40+3,:x
        adc &32
      end
      inx
      cpx &32
      bne :loop
    end

  end

  label :main do
    jmp :main
  end

  segment :charset do
    byte bmp.data
  end

end

prg.write
