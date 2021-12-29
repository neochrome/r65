module C64
  module VIC2

    class Config
      attr_reader :bank, :screen_rel, :char_rel

      def initialize
        @bank = 0x0000
        @screen_rel = DefaultScreen
        @char_rel = 0x1000
      end

      def bank_at (address)
        raise RangeError, "Invalid bank address: 0x%04x" % address unless (0x0000..0xc000).include? address and address.divisible_by? 0x4000
        @bank = address
        self
      end

      def bank_config
        (0xc000 - @bank) >> 14
      end

      def mem_config
        screen_config + char_config
      end

      def screen_at (address)
        raise RangeError, "Invalid screen address: 0x%04x" % address unless (0x0000..0x3c00).include? address and address.divisible_by? 0x400
        @screen_rel = address
        self
      end

      def screen_config
        (@screen_rel / 0x400) << 4
      end

      def screen
        @bank + @screen_rel
      end

      def char_at (address)
        raise RangeError, "Invalid char address: 0x%04x" % address unless (0x0000..0x3800).include? address and address.divisible_by? 0x800
        @char_rel = address
        self
      end

      def char_config
        (@char_rel / 0x800) << 1
      end

      def char
        @bank + @char_rel
      end

      def bitmap_at (address)
        raise RangeError, "Invalid bitmap address: 0x%04x" % address unless [0x0000,0x2000].include? address
        char_at 0x2000
      end

      def bitmap_rel
        char_config[3] << 13
      end

      def bitmap
        @bank + bitmap_rel
      end

      def init
        bank = bank_config
        mem = mem_config

        proc do
          label :vic2_init
          lda VIC2::Bank::SetupRegister
          ana &VIC2::Bank::Mask
          ora &bank
          sta VIC2::Bank::SetupRegister

          lda &mem
          sta VIC2::Memory::SetupRegister
        end
      end

      def sprite_data (data_label, frame = 0)
        (data_label % 0x4000) / 64 + frame
      end

      def sprite_pointer (sprite = 0)
        screen + 0x3f8 + sprite
      end

      def sprite_x (sprite = 0)
        VIC2::Sprite::X[sprite]
      end

      def sprite_y (sprite = 0)
        VIC2::Sprite::Y[sprite]
      end

      def sprite_x_bit8
        VIC2::Sprite::XBit8
      end

      def sprite_color (sprite = 0)
        VIC2::Sprite::Color[sprite]
      end

      def color
        VIC2::Color
      end

    end

  end
end
