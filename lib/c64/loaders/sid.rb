module C64
  module Loaders
    class Sid

      def self.from_file (filename)
        File.open filename, "rb" do |f|
          data = f.read.bytes
          Sid.new data
        end
      end

      attr_reader :start, :init, :play, :data

      def initialize (data)
        version = data.word(4)
        data_offset = data.word_be(6)
        @start = data.word(data_offset)
        @init = data.word_be(0x0a)
        @play = data.word_be(0x0c)
        @data = data.drop(data_offset + 2)
      end

    end
  end
end
