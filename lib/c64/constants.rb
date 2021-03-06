module C64
  # http://www.awsm.de/mem64/

  module DefaultBasic
    Start = 0x801
  end

  module ROMConfig
    # https://www.c64-wiki.com/wiki/Bank_Switching
    ControlRegister = 0x0001
    Default = 0b00110111
    IO      = 0b00000100
    Basic   = 0b00000001
    Kernal  = 0b00000010
    NoIO     = Default & !IO
    NoBasic  = Default & !Basic
    NoKernal = Default & !Kernal
  end

  module CIA1
    module IRQ
      ControlRegister = 0xdc0d
      TimerA     = 0b00000001
      TimerB     = 0b00000010
      TimeOfDay  = 0b00000100
      Serial     = 0b00001000
      Flag       = 0b00010000
      Enable     = 0b10000000
      DisableAll = TimerA | TimerB | TimeOfDay | Serial | Flag
    end

    # https://www.c64-wiki.com/wiki/Keyboard
    module PortA
      DataDirection = 0xdc02
      Outputs = 0xff
      Inputs = 0x00
      Data = 0xdc00
    end

    module PortB
      DataDirection = 0xdc03
      Outputs = 0xff
      Inputs = 0x00
      Data = 0xdc01
    end
  end

  module CIA2
    module IRQ
      ControlRegister = 0xdd0d
      TimerA     = 0b00000001
      TimerB     = 0b00000010
      TimeOfDay  = 0b00000100
      Serial     = 0b00001000
      Flag       = 0b00010000
      Enable     = 0b10000000
      DisableAll = TimerA | TimerB | TimeOfDay | Serial | Flag
    end
  end

  module VIC2
    Base = 0xd000
    DefaultScreen = 0x0400
    Color = Base + 0x800
    RasterCounter = Base + 0x12
    BorderColor = Base + 0x20
    BackgroundColor = Base + 0x21

    module Control1
      Register = Base + 0x11
      Default            = 0b00011011
      VScrollMask        = 0b11111000
      Bitmap             = 0b00100000
      Height25           = 0b00001000
      ScreenOn           = 0b00010000
      ExtendedBackground = 0b01000000
      RasterBit8         = 0b10000000
    end

    module Control2
      Register = Base + 0x16
      Default     = 0b11001000
      HScrollMask = 0b11111000
      Width40     = 0b00001000
      Multicolor  = 0b00010000
    end

    module IRQ
      StatusRegister = Base + 0x19
      ControlRegister = Base + 0x1a
      Raster                    = 0b00000001
      CollisionSpriteBackground = 0b00000010
      CollisionSpriteSprite     = 0b00000100
      VectorLo = 0xfffe
      VectorHi = 0xffff
    end

    # https://codebase64.org/doku.php?id=base:vicii_memory_organizing
    module Memory
      SetupRegister = Base + 0x18
      CharMask   = 0b11110000
      Char0x0000 = 0b00000000
      Char0x0800 = 0b00000010
      Char0x1000 = 0b00000100
      Char0x1800 = 0b00000110
      Char0x2000 = 0b00001000
      Char0x2800 = 0b00001010
      Char0x3000 = 0b00001100
      Char0x3800 = 0b00001110
      CharDefault= Char0x1000
      Bitmap0x0000 = 0b00000000
      Bitmap0x2000 = 0b00001000
      ScreenMask   = 0b00001111
      Screen0x0000 = 0b00000000
      Screen0x0400 = 0b00010000
      Screen0x0800 = 0b00100000
      Screen0x0c00 = 0b00110000
      Screen0x1000 = 0b01000000
      Screen0x1400 = 0b01010000
      Screen0x1800 = 0b01100000
      Screen0x1c00 = 0b01110000
      Screen0x2000 = 0b10000000
      Screen0x2400 = 0b10010000
      Screen0x2800 = 0b10100000
      Screen0x2c00 = 0b10110000
      Screen0x3000 = 0b11000000
      Screen0x3400 = 0b11010000
      Screen0x3800 = 0b11100000
      Screen0x3c00 = 0b11110000
      ScreenDefault= Screen0x0400
      SelectCharset = proc do |address:nil, index:nil|
        raise ArgumentError, "You must supply either address or index" unless address.nil? ^ index.nil?
        config = CharDefault
        unless address.nil?
          raise RangeError, "Address must be between 0x0000 and 0x3800, was %04x" % address unless (0x0000..0x3800).include? address
          raise RangeError, "Address must be divisible by 0x0800" unless address.divisible_by? 0x0800
          config = (address / 0x0800) << 1
        end
        unless index.nil?
          raise RangeError, "Index must be between 0 and 7, was #{index}" unless (0..7).include? index
          config = index << 1
        end
        lda SetupRegister
        ana &CharMask
        ora &config
        sta SetupRegister
      end
    end

    module Bank
      SetupRegister = Base + 0x0d00
      Mask       = 0b11111100
      Bank0x0000 = 0b00000011 # supports ROM chars
      Bank0x4000 = 0b00000010
      Bank0x8000 = 0b00000001 # supports ROM chars
      Bank0xc000 = 0b00000000
      BankDefault= Bank0x0000
    end

    module Sprite
      # individual values
      X = Array.new(8).map.with_index{|_,i|Base + i * 2}
      XBit8 = Base + 0x10
      Y = Array.new(8).map.with_index{|_,i|Base + i * 2 + 1}
      Color = Array.new(8).map.with_index{|_,i|Base + 0x27 + i}
      DefaultPointer = Array.new(8).map.with_index{|_,i|0x07f8 + i}
      # registers
      DoubleHeightRegister = Base + 0x17
      DoubleWidthRegister = Base + 0x1d
      PriorityRegister = Base + 0x1b
      MulticolorRegister = Base + 0x1c
      CollisionSpriteRegister = Base + 0x1e
      CollisionBackgroundRegister = Base + 0x1f
      EnableRegister = Base + 0x15
      # common settings
      Multicolor1 = Base + 0x25
      Multicolor2 = Base + 0x26
    end

    module Colors
      Black      = 0x00
      White      = 0x01
      Red        = 0x02
      Cyan       = 0x03
      Purple     = 0x04
      Green      = 0x05
      Blue       = 0x06
      Yellow     = 0x07
      Orange     = 0x08
      Brown      = 0x09
      LightRed   = 0x0a
      DarkGrey   = 0x0b
      DarkGray   = 0x0b
      Grey       = 0x0c
      LightGreen = 0x0d
      LightBlue  = 0x0e
      LightGrey  = 0x0f
      LightGray  = 0x0f
    end

  end

end
