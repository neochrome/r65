require_relative "../constants"

module C64
  module Macros
    module Utils

      DebugRaster = proc do |color: VIC2::Colors::Black|
        if defined? DEBUG
          lda &color
          sta VIC2::BorderColor
        end
      end

      ClearScreen = proc do |color: VIC2::Colors::Black, fillbyte: 0x20, screen: VIC2::DefaultScreen|
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

      LoadScreen = proc do |screen_data:, screen: VIC2::DefaultScreen, color_data: nil, color: VIC2::Color|
        ldx &0
        label :copy do
          [0x000,0x100,0x200,0x2e8].each do |offset|
            lda screen_data+offset,:x
            sta screen+offset,:x
            unless color_data.nil?
              lda color_data+offset,:x
              sta color+offset,:x
            end
          end
          inx
          bne :copy
        end
      end

    end
  end
end
