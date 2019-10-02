require "chunky_png"
require_relative "../../../lib/c64"

describe C64::Loaders::Bitmap::MultiColor do
  Bitmap = C64::Loaders::Bitmap::MultiColor
  Palette = C64::Loaders::Bitmap::DefaultPalette

  it "requires a source image with dimensions divisible by 8" do
    expect{ Bitmap.new ChunkyPNG::Image.new 10, 8 }.to raise_error(ArgumentError)
    expect{ Bitmap.new ChunkyPNG::Image.new 8, 10 }.to raise_error(ArgumentError)
  end

  it "keeps the dimensions of source image" do
    bmp = Bitmap.new (ChunkyPNG::Image.new 320, 200)
    expect(bmp.width).to eq 320
    expect(bmp.height).to eq 200
  end

  it "fails if more than 4 different colors used in an 8x8 area" do
    img = [
      0,0,1,1,2,2,3,3,
      4,4,1,1,2,2,3,3,
      0,0,1,1,2,2,3,3,
      0,0,1,1,2,2,3,3,
      0,0,1,1,2,2,3,3,
      0,0,1,1,2,2,3,3,
      0,0,1,1,2,2,3,3,
      0,0,1,1,2,2,3,3,
    ].to_image 8, 8
    expect{ Bitmap.new img }.to raise_error(RangeError)
  end

  it "uses most common color across areas as background" do
    img = [
      0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
      0,0,1,1,1,1,1,1, 1,1,1,1,1,1,0,0,
      0,0,1,1,1,1,1,1, 1,1,1,1,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,

      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,2,2,2,2, 2,2,2,2,1,1,0,0,
      0,0,1,1,1,1,1,1, 1,1,1,1,1,1,0,0,
      0,0,1,1,1,1,1,1, 1,1,1,1,1,1,0,0,
      0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
    ].to_image 16, 16
    bmp = Bitmap.new img
    expect(bmp.background_color).to eq 0
  end

  it "packs data for a single area bitmap" do
    img = [
      0,0,1,1,2,2,2,2,
      0,0,1,1,2,2,2,2,
      0,0,1,1,2,2,2,2,
      1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,
      0,0,1,1,3,3,3,3,
      0,0,1,1,3,3,3,3,
      0,0,1,1,3,3,3,3,
    ].to_image 8, 8
    bmp = Bitmap.new img, background_color: Palette[0]
    expect(bmp.data).to eq [
        0b00011010,
        0b00011010,
        0b00011010,
        0b01010101,
        0b01010101,
        0b00011111,
        0b00011111,
        0b00011111,
      ]
  end

  it "packs data for a two area bitmap" do
    img = [
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
      1,1,1,1,0,0,0,0, 0,0,0,0,1,1,1,1,
    ].to_image 16, 8
    bmp = Bitmap.new img, background_color: Palette[0]
    expect(bmp.data).to eq [
        0b01010000,
        0b01010000,
        0b01010000,
        0b01010000,
        0b01010000,
        0b01010000,
        0b01010000,
        0b01010000,

        0b00000101,
        0b00000101,
        0b00000101,
        0b00000101,
        0b00000101,
        0b00000101,
        0b00000101,
        0b00000101,
      ]
  end

end
