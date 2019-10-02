require_relative "./op_codes"
require_relative "./addressing"

module R65

  class Data
    def initialize (byte)
      raise RangeError, "0x%02x is out of range (0x00 - 0xff)" % byte unless (0x00..0xff).include? byte
      @byte = byte
    end
    def to_s
      "%02x" % @byte
    end
    def size
      1
    end
    def as_bytes
      [@byte]
    end
    def assemble!
    end
  end

  class Label
    def initialize (name)
      @name = name
    end
    def to_s
      @name
    end
    def size
      0
    end
    def assemble!
    end
  end

  class Instruction
    attr_reader :name

    def initialize (pc, name, modes, scope, args, src)
      @pc = pc
      @name = name
      @scope = scope
      @op_code = nil
      @mode = nil
      @arg = nil
      @bytes = []
      @src = src

      # detect noargs
      if modes.has_key? :impl and args.empty?
        @mode = :impl
        @op_code = modes[@mode]
        @resolved = true
        return
      end
      raise ArgumentError, "Missing argument(s) for #{@name}" if args.empty?

      # detect immidiate
      if args.last == :imm
        raise TypeError, "Immidiate value not supported for #{@name}" unless modes.has_key? :imm
        @mode = :imm
        @op_code = modes[@mode]
        @arg = Addressing::Expression.from(args.first)
        return
      end

      # detect indirect
      indirect = case args.first
        when Array
          raise ArgumentError, "Only *one* indirect address allowed: #{args.first}" unless args.first.size == 1
          args.first.first
        else
          nil
        end

      # detect indexed / zeropage modifier
      indexed, zeropage = (case args.last
        when :x,:y,nil
          [args.last, nil]
        when :z
          [nil,:zpg]
        when :zx
          [:x,:zpg]
        when :zy
          [:y,:zpg]
        else
          raise ArgumentError, "Unsupported mode modifier :#{args.last}"
        end) if args.size > 1

      # if only one mode is specified, use as default
      if modes.size == 1
        @mode = modes.keys.first
        @op_code = modes[@mode]
      end

      @arg = Addressing::Expression.from(indirect || args.first)
      @mode = ((indirect ? "ind" : zeropage ? zeropage.to_s : @mode ? @mode.to_s : "abs") + (indexed ? indexed.to_s : "")).to_sym
      raise ArgumentError, "Unsupported addressing mode #{@mode} for #{@name}" unless modes.has_key? @mode
      @op_code = modes[@mode]

      # handle relative addressing
      if @mode == :rel and not @arg.pending?
        @arg = Addressing::BinaryExpression.new @arg, Addressing::Expression.from(@pc), :+
      end
    end

    def size
      1 + case @mode
      when :impl
        0
      when :imm,:zpg,:zpgx,:zpgy,:indx,:indy,:rel
        1
      when :ind,:abs,:absx,:absy
        2
      else
        raise NotImplementedError, "Unsupported mode: #{@mode}"
      end
    end

    def assemble!
      return unless @bytes.empty?
      begin
        @arg.resolve! do |label|
          @scope.resolve_label label
        end unless @arg.nil?
        @bytes = [@op_code]
        case @mode
        when :impl
        when :rel
          target = (@arg.value - @pc - 2)
          raise RangeError, "Branch target %04x too far (%d), must be within -128..127" % [@arg.value, target] unless (-128..127).include? target
          @bytes << target.twos_complement
        when :imm,:zpg,:zpgx,:zpgy,:indx,:indy
          raise RangeError, ("0x%x is out of range (0x00..0xff)" % @arg.value) unless (0x00..0xff).include? @arg.value
          @bytes << @arg.value
        when :ind,:abs,:absx,:absy
          raise RangeError, ("0x%x is out of range (0x0000..0xffff)" % @arg.value) unless (0x00..0xffff).include? @arg.value
          @bytes += [@arg.value.lo_b,@arg.value.hi_b]
        else
          raise NotImplementedError, "Unsupported mode: #{@mode}"
        end
      rescue => err
        err.backtrace.unshift @src
        raise err
      end
    end

    def to_s
      value = case @mode
        when :imm
          "&%02x" % @arg.value
        when :impl
          ""
        when :zpg,:zpgx,:zpgy,:indx,:indy
          "%02x" % @arg.value
        when :rel
          "%04x" % @arg.value
        else
          "%04x" % @arg.value
        end
      "%-23s  %s %s" % [@bytes.map{|b|"%02x" % b}.join(" "), @name, value]
    end

    def as_bytes
      @bytes
    end

  end

end
