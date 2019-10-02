module C64
  module Loaders

    require "json"

    # https://www.spritemate.com/
    module Spritemate

      def self.from_file (filename)
        File.open filename, "r" do |f|
          data = JSON.parse f.read
          colors = data["colors"]
          multicolor1 = colors["2"]
          multicolor2 = colors["3"]
          background = colors["0"]

          frames = data["sprites"].map{|sprite|Frame.from_data sprite}

          sprites = frames
            .chunk{|frame|frame.name}
            .to_h
            .transform_values{|frames|
              Sprite.new(
                name: frames.first.name,
                multicolor1: multicolor1,
                multicolor2: multicolor2,
                background: background,
                frames: frames
              )
            }
          sprites
        end
      end

      class Sprite
        attr_reader :name, :multicolor1, :multicolor2, :background, :frames

        def initialize (name:, multicolor1:, multicolor2:, background:, frames:)
          @name = name
          @multicolor1 = multicolor1
          @multicolor2 = multicolor2
          @background = background
          @frames = frames
        end

        def multicolor?
          @frames.any?(&:multicolor?)
        end

        def double_x?
          @frames.any?(&:double_x?)
        end

        def double_y?
          @frames.any?(&:double_y?)
        end

      end

      class Frame
        attr_reader :data, :name, :color

        def self.from_data (data)
          Frame.new(
            name: data["name"],
            multicolor: data["multicolor"],
            pixels: data["pixels"],
            color: data["color"],
          )
        end

        def initialize (name:, pixels:, multicolor: false, color: 0, double_x: false, double_y: false)
          @name = name
          @multicolor = multicolor
          @data = pixels.map{|row|
            @multicolor ? pack_multicolor(row) : pack_singlecolor(row)
          }.flatten << 0 # pad to 64 bytes
          @color = color
          @double_x = double_x
          @double_y = double_y
        end

        def multicolor?
          @multicolor
        end

        def double_x?
          @double_x
        end

        def double_y?
          @double_y
        end

        private

        def pack_singlecolor (row)
          row
            .each_slice(8) # 8 pixel chunks
            .map{|c|
            c
              .map{|p|[p,1].min} # cap pixel to [0..1]
              .join() # build bitstring
              .to_i(2) # parse as number
          }
        end

        def pack_multicolor (row)
          row
            .each_slice(8) # 8 pixel chunks
            .map{|c|
            c
              .each_slice(2) # use even indexed
              .map{|p|["00","10","01","11"][p.first]} # convert to bits
              .join() # build bitstring
              .to_i(2) # parse as number
          }
        end

      end

    end
  end
end
