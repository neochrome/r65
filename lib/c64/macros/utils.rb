require_relative "../constants"

module C64
  module Macros
    module Utils

      DebugRaster = proc do |color: 0|
        if defined? DEBUG
          lda &color
          sta VIC2::BorderColor
        end
      end

      ClearScreen = proc do |color: 0, fillbyte: 0x20, screen: VIC2::DefaultScreen|
        lda &color
        sta VIC2::BackgroundColor
        sta VIC2::BorderColor

        lda &fillbyte
        ldx &0
        label :clear do
          [0x000,0x100,0x200,0x2e8].each do |offset|
            sta screen+offset,:x
          end
          inx
          bne :clear
        end
      end

      LoadScreen = proc do |src:, dst: VIC2::DefaultScreen|
        ldx &0
        label :copy do
          [0x000,0x100,0x200,0x2e8].each do |offset|
            lda src+offset,:x
            sta dst+offset,:x
          end
          inx
          bne :copy
        end
      end

    end
  end
end
