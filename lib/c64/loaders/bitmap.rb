module C64
  module Loaders
    module Bitmap

      require "chunky_png"

      # from https://www.c64-wiki.com/wiki/Color
      DefaultPalette = [
        [  0,  0,  0], # black
        [255,255,255], # white
        [136,  0,  0], # red
        [170,255,238], # cyan
        [204, 68,204], # purple
        [  0,204, 85], # green
        [  0,  0,170], # blue
        [238,238,119], # yellow
        [221,136, 85], # orange
        [102, 68,  0], # brown
        [255,119,119], # light red
        [ 51, 51, 51], # dark grey / grey 1
        [119,119,119], # grey / grey 2
        [170,255,102], # light green
        [  0,136,255], # light blue
        [187,187,187], # light grey / grey 3
      ].map{|r,g,b|ChunkyPNG::Color.rgb(r,g,b)}

      class Base
        attr_reader :width, :height, :data, :cols, :rows, :background_color

        BlockSize = 8

        def initialize (src, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          @src,@palette = src,palette
          raise ArgumentError, "Source image must have a width divisible by #{BlockSize}, was #{src.width}" unless src.width.divisible_by? BlockSize
          raise ArgumentError, "Source image must have a height divisible by #{BlockSize}, was #{src.height}" unless src.height.divisible_by? BlockSize
          @width,@height = src.width,src.height
          @background_color = palette_index background_color

          @cols = @width / BlockSize
          @rows = @height / BlockSize
          @data = []
        end

        def palette_index (color)
          idx = @palette.find_index ChunkyPNG::Color.opaque!(color)
          raise IndexError, "No matching palette index found for: #{color}" if idx.nil?
          idx
        end

        def each_area
          0.step(@src.height - 1, BlockSize) do |oy|
            0.step(@src.width - 1, BlockSize) do |ox|
              yield ox,oy if block_given?
            end
          end
        end

      end

      class Standard < Base
        attr_reader :screen

        def self.from_file (filename, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          self.new ChunkyPNG::Image.from_file(filename), palette: palette, background_color: background_color
        end

        def initialize (src, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          super src, palette: palette, background_color: background_color

          @screen = []
          each_area do |ox,oy|
            colors = []
            (0..7).each do |y|
              byte = 0
              (0..7).each do |x|
                color = palette_index(@src[ox+x,oy+y])
                colors << color unless colors.any? color
                raise RangeError, "More than 2 unique colors in area (#{ox+1},#{oy+1})-(#{ox+8},#{oy+8})" if colors.size > 2
                b = colors.find_index color
                byte += (b << (7-x))
              end
              @data << byte
            end
            @screen << ((colors[1] || 0) << 4) + (colors[0] || 0)
          end

          raise "Bad data size:#{@data.size}" if @data.size != @src.width * @src.height / 8
          raise "Bad screen size:#{@screen.size}" if @screen.size != @src.width * @src.height / 64
        end

      end

      class MultiColor < Base
        attr_reader :screen, :color

        def self.from_file (filename, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          self.new ChunkyPNG::Image.from_file(filename), palette: palette, background_color: background_color
        end

        def initialize (src, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          super src, palette: palette, background_color: background_color

          @screen = []
          @color = []
          each_area do |ox,oy|
            colors = [@background_color]
            (0..7).each do |y|
              byte = 0
              0.step 7, 2 do |x|
                color = palette_index(@src[ox+x,oy+y])
                colors << color unless colors.any? color
                raise RangeError, "More than 3+1 unique colors in area (#{ox+1},#{oy+1})-(#{ox+8},#{oy+8})" if colors.size > 4
                b = colors.find_index color
                byte += (b << (6-x))
              end
              @data << byte
            end
            @screen << ((colors[1] || 0) << 4) + (colors[2] || 0)
            @color << (colors[3] || 0)
          end

          raise "Bad data size:#{@data.size}" if @data.size != @src.width * @src.height / 8
          raise "Bad screen size:#{@screen.size}" if @screen.size != @src.width * @src.height / 64
        end

      end

      class SingleColor < Base
        def self.from_file (filename, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          self.new ChunkyPNG::Image.from_file(filename), palette: palette, background_color: background_color
        end

        def initialize (src, palette: DefaultPalette, background_color: ChunkyPNG::Color::BLACK)
          super src, palette: palette, background_color: background_color

          each_area do |ox,oy|
            (0..7).each do |y|
              byte = 0
              (0..7).each do |x|
                byte += (1 << (7-x)) if palette_index(@src[ox+x,oy+y]) != @background_color
              end
              @data << byte
            end
          end

          raise "Bad data size:#{@data.size}" if @data.size != @src.width * @src.height / 8
        end

        def invert!
          @data.map! do |b|
            ~b & 0xff
          end
        end

      end

    end

  end
end
