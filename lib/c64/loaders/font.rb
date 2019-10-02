module C64
  module Loaders

    class Font

      class Glyph
        attr_reader :char, :width, :height, :codes

        def initialize (char:, width:, height:, codes:)
          @char,@width,@height = char,width,height
          @codes = codes
        end

        def [](x,y)
          @codes[x + y * @width]
        end

        def size
          @codes.size
        end
      end

      def initialize (bitmap, width:, height:, charmap:, offset: 0)
        raise ArgumentError, "bitmap must be of type Loaders::Bitmap::*" unless bitmap.kind_of? Loaders::Bitmap::Base
        raise RangeError, "offset (#{offset}) must be positive" if offset < 0
        raise RangeError, "character width must be positive, was #{width}" unless width > 0
        raise RangeError, "character height must be positive, was #{height}" unless height > 0
        raise ArgumentError, "charmap must not be empty" if charmap.size.zero?

        @width,@height = width,height
        @offset,@charmap = offset,charmap
        @glyphs = charmap.chars.each_with_index.map do |ch, idx|
          codes = @height.times.to_a.map do |row|
            col_offset = (@offset + idx) * @width % bitmap.cols
            row_offset = col_offset / bitmap.cols
            target_row = row_offset + row
            @width.times.to_a.map do |col|
              target_col = col_offset + col
              unless (0...bitmap.rows).include? target_row and (0...bitmap.cols).include? target_col
                raise RangeError,"charmap (row: #{target_row}, col: #{target_col}) outside image bounds (rows: #{bitmap.rows}, cols: #{bitmap.cols})"
              end
              target_col + target_row * bitmap.cols
            end
          end.flatten
          Glyph.new char: ch, width: @width, height: @height, codes: codes
        end
      end

      def [](ch)
        idx = @charmap.index ch
        raise RangeError, "The character: #{ch}, is not in the charmap: #{@charmap}" unless idx
        @glyphs[idx]
      end

      def to_glyphs (s)
        s.chars.map{|ch|self[ch]}
      end

    end

  end
end
