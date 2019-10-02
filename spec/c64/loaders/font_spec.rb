require "chunky_png"
require_relative "../../../lib/c64"

describe C64::Loaders::Font do
  Font = C64::Loaders::Font

  describe "#initialize" do
    before { @bmp = C64::Loaders::Bitmap::SingleColor.new ChunkyPNG::Image.new 16, 16 }
    before { @valid_options = { charmap: "A", width: 2, height: 2 } }

    it "works" do
      expect{ Font.new @bmp, **@valid_options }.not_to raise_error
    end

    it "requires a bitmap" do
      expect{ Font.new (ChunkyPNG::Image.new 16, 16), **@valid_options }.to raise_error ArgumentError
    end

    it "requires a positive offset" do
      expect{ Font.new @bmp, **{ **@valid_options, offset: -1 } }.to raise_error RangeError
    end

    it "requires a non-empty charmap" do
      expect{ Font.new @bmp, **{ **@valid_options, charmap: "" } }.to raise_error ArgumentError
    end

  end

end
