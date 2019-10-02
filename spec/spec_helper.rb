require "chunky_png"
require_relative "../lib/c64/loaders/bitmap"

class Array
  def to_image (w, h)
    img = ChunkyPNG::Image.new w, h
    h.times do |y|
      w.times do |x|
        img[x,y] = C64::Loaders::Bitmap::DefaultPalette[self[y*w+x]]
      end
    end
    img
  end
end
