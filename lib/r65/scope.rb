require_relative "./instructions"

module R65

  class Scope
    attr_reader :name
    attr_reader :parent
    attr_reader :labels

    def initialize (segments, segment, parent = nil, name = "", &block)
      @segments = segments
      @segment = segment
      @name = name
      @parent = parent
      @labels = {}

      try_with_local_trace do
        instance_eval(&block) unless block.nil?
      end
    end

    def scope (name = "<scope>", &block)
      Scope.new @segments, @segment, self, name.to_s, &block
    end

    def label (name, &block)
      raise "Label :#{name} is already defined in current scope" if @labels.has_key? name
      @labels[name] = @segment.pc
      full_name = name.to_s
      traverse do |scope|
        full_name = scope.name + ":" + full_name
      end
      @segment.add Label.new full_name
      scope name, &block unless block.nil?
    end

    def resolve_label (name)
      pc = nil
      traverse do |scope|
        pc = scope.labels[name] unless pc
      end
      raise "Could not resolve label :#{name}" unless pc
      pc
    end

    def segment (name, in_scope: false, &block)
      raise "No such segment: #{name}" unless new_segment = @segments.find {|seg|seg.name == name}
      if in_scope
        old_segment = @segment
        @segment = new_segment
        try_with_local_trace do
          instance_eval(&block) unless block.nil?
        end
        @segment = old_segment
      else
        Scope.new @segments, new_segment, @parent, "<scope>", &block unless block.nil?
      end
    end

    def segment! (name)
      raise "No such segment: #{name}" unless segment = @segments.find {|seg|seg.name == name}
      @segment = segment
    end

    def byte (*bytes)
      bytes.flatten.each do |b|
        case b
        when Integer
          @segment.add Data.new b
        else
          raise ArgumentError, "Argument '#{b}' of unsupported type #{b.class}"
        end
      end
    end

    def word (*words)
      words.flatten.map do |w|
        byte [w.lo_b,w.hi_b]
      end
    end

    def fill (n, byte)
      byte Array.new n,byte
    end

    def pc! (address)
      @segment.pc! address
    end

    def align! (alignment)
      raise RangeError, "Alignment (#{alignment}) must be positive" if alignment < 0
      raise ArgumentError, "Alignment (#{alignment}) must be a power of two" unless (alignment & (alignment - 1)) == 0
      until @segment.pc & (alignment - 1) == 0 do
        pc! @segment.pc + 1
      end
    end

    def method_missing (name, *args, &immidiate)
      raise NoMethodError, "No such instruction: #{name}" unless OP_CODES.has_key? name
      raise ArgumentError, "Immidiate values doesn't have parameters" if immidiate and args.size > 0
      args = [immidiate.call,:imm] if immidiate
      ins = Instruction.new @segment.pc, name, OP_CODES[name], self, args, caller.first
      @segment.add ins
    end

    def call (macro, *args, **kwargs, &block)
      kwargs[:block] = block if block
      scope.instance_exec(*args, **kwargs, &macro)
    end

    private

    def try_with_local_trace
      begin
        yield
      rescue => err
        err.backtrace.reject!{|bt|bt.include? __dir__} unless defined? DEBUG
        raise err
      end
    end

    def traverse ()
      s = self
      while !s.nil?
        yield s
        s = s.parent
      end
    end

  end

end
