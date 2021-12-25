require_relative "./instructions"

module R65

  class Scope
    attr_reader :name
    attr_reader :parent
    attr_reader :labels
    attr_reader :scopes

    def initialize (segments, segment, parent = nil, name = "", &block)
      @segments = segments
      @segment = segment
      @name = name
      @parent = parent
      @labels = {}
      @scopes = []

      try_with_local_trace do
        instance_eval(&block) unless block.nil?
      end
    end

    def scope (name = "_", &block)
      s = Scope.new @segments, @segment, self, name.to_s, &block
      scopes << s
      s
    end

    def label (name, *checkpoint_configuration, &block)
      raise ArgumentError, "Label :#{name} is already defined in current scope" if @labels.has_key? name
      @labels[name] = @segment.pc
      full_name = name.to_s
      traverse_up do |scope|
        full_name = scope.name + ":" + full_name
      end
      checkpoints = checkpoint_configuration.map{|cfg|Label::Checkpoint.from cfg}.flatten
      @segment.add Label.new full_name, checkpoints: checkpoints
      scope name, &block unless block.nil?
    end

    def resolve_label (name)
      # check up in chain
      traverse_up do |scope|
        return scope.labels[name] if scope.labels.has_key? name
      end

      # check from root
      label_qname = "#{root.full_name}:#{name.to_s}"
      root.traverse_down do |s|
        s.labels.each_pair do |lbl,addr|
          return addr if "#{s.full_name}:#{lbl.to_s}" == label_qname
        end
      end

      # check from current
      current = parent.nil? ? self : parent
      label_qname = "#{current.full_name}:#{name.to_s}"
      current.traverse_down do |s|
        s.labels.each_pair do |lbl,addr|
          return addr if "#{s.full_name.delete_prefix self.full_name}:#{lbl.to_s}" == label_qname
        end
      end

      raise ArgumentError, "Could not resolve label :#{name}"
    end

    def segment (name, scope: nil, &block)
      raise "No such segment: #{name}" unless new_segment = @segments.find {|seg|seg.name == name}
      if scope.nil?
        old_segment = @segment
        @segment = new_segment
        try_with_local_trace do
          instance_eval(&block) unless block.nil?
        end
        @segment = old_segment
        return self
      else
        s = Scope.new @segments, new_segment, @parent, scope.to_s, &block
        @scopes << s
        return s
      end
    end

    def segment! (name)
      raise "No such segment: #{name}" unless segment = @segments.find {|seg|seg.name == name}
      @segment = segment
      self
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

    def fill (n, byte = 0x00)
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
      self.instance_exec(*args, **kwargs, &macro)
    end

    def call_with_scope (macro, *args, scope: "_", **kwargs, &block)
      kwargs[:block] = block if block
      scope(scope).instance_exec(*args, **kwargs, &macro)
    end

    protected

    def try_with_local_trace
      begin
        yield
      rescue => err
        err.backtrace.reject!{|bt|bt.include? __dir__} unless defined? $DEBUG
        raise err
      end
    end

    def traverse_up ()
      s = self
      while !s.nil?
        yield s
        s = s.parent
      end
    end

    def traverse_down (&block)
      yield self
      scopes.each do |s|
        s.traverse_down &block
      end
    end

    def root ()
      r = self
      while true
        break if r.parent.nil?
        r = r.parent
      end
      r
    end

    def full_name
      return @name if @parent.nil?
      "#{@parent.full_name}:#{@name}"
    end

  end

end
