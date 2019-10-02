require_relative "./instructions"

module R65

  class Segment
    attr_reader :min,:max,:start,:pc,:name,:fill

    def initialize (name, min: nil, max: nil, start: nil, fill: nil)
      @name = name
      @min,@max,@start = min,max,start
      @min ||= @start || 0x0000
      @start ||= @min || 0x0000
      @range = @min..(@max || 0xffff)
      max_range = 0x0000..0xffff
      raise RangeError, "Min (0x%04x) must be between 0x0000 - 0xffff" % @min unless max_range.include? @min
      raise RangeError, "Max (0x%04x) must be between 0x0000 - 0xffff" % @max if @max and not max_range.include? @max
      raise RangeError, "Min (0x%04x) must not be greater than max (0x%04x)" % [@min, @max] if @max and @min > @max
      raise RangeError, "Start (0x%04x) must be between min/max (0x%04x - 0x%04x)" % [@start, @range.min, @range.max] unless @range.include? @start
      @fill = fill.is_a?(Integer) ? fill & 0xff : nil
      @instructions = []
      @pc = @start
    end

    def add (instruction)
      case instruction
      when Data, Instruction
        raise RangeError, ("PC 0x%04x will be outside segment (0x%04x - 0x%04x)" % [@pc, @range.min, @range.max]) if @pc + instruction.size > @range.max + 1
      when Label
      else
        raise NotImplementedError, "Unsupported instruction type: #{instruction.class}"
      end
      @instructions << [@pc, instruction]
      @pc += instruction.size
    end

    def pc! (address)
      raise RangeError, "Can't set pc lower (0x%04x) than current (0x%04x)" % [address, @pc] unless address >= @pc
      raise RangeError, "PC 0x%04x will be outside segment (0x%04x - 0x%04x)" % [address, @range.min, @range.max] unless @range.include? address
      if @fill or @pc != @start
        (address - @pc).times do
          add Data.new (@fill || 0x00)
        end
      else
        @start = address if @pc == @start
        @pc = address
      end
    end

    def assemble!
      @instructions.each do |pc,ins|
        ins.assemble!
      end
    end

    def as_bytes (fill_before: false, fill_after: false)
      assemble!
      bytes = @instructions
        .select{|pc,ins|ins.respond_to? :as_bytes}
        .map{|pc,ins|ins.as_bytes}
        .flatten
      bytes = (Array.new (@start - @min), @fill || 0x00) + bytes if fill_before or @fill
      bytes += (Array.new (@range.max - @pc), @fill || 0x00) if fill_after or (@fill and @max)
      bytes
    end

    def to_s
      ".#{@name}\n" + @instructions
        .chunk{|addr,ins|ins.class}
        .map{|kind,instructions|
          if kind == Data
            next instructions.each_with_index.chunk{|ins,i|i/8}.map{|_,items|
              addr = items[0][0][0]
              data = items.map{|(addr,ins),_|"%02x" % ins.as_bytes}.join(" ")
              [addr, data]
            }
          else
            next instructions
          end
        }
        .flatten(1)
        .map{|addr,ins| "%04x: %s" % [addr,ins]}
        .join("\n")
    end

  end

end
