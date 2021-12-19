require_relative "../../lib/r65"

describe R65::Scope do

  describe "#align" do
    before do
      @seg = R65::Segment.new :code
      @scope = R65::Scope.new [@seg], @seg
    end

    it "can align pc, v1" do
      @scope.pc! 0x10f0
      @scope.align! 0x100

      expect(@seg.pc).to eq 0x1100
    end

    it "can align pc, v2" do
      @scope.pc! 0xf0
      @scope.align! 0x1000

      expect(@seg.pc).to eq 0x1000
    end

    it "fails if alignment is negative" do
      expect{ @scope.align! -1 }.to raise_error RangeError
    end

    it "fails if alignment is not power of 2" do
      expect{ @scope.align! 3 }.to raise_error ArgumentError
    end

  end

  describe "label scoping" do
    before do
      @code = R65::Segment.new :code
      @data = R65::Segment.new :data
      @scope = R65::Scope.new [@code, @data], @code
    end

    it "resolves a label in current scope" do
      @scope.pc! 1
      @scope.label :a_label

      expect(@scope.resolve_label :a_label).to eq 1
    end

    it "fails to resolve a non-existing" do
      expect{ @scope.resolve_label :missing }.to raise_error ArgumentError
    end

    it "fails to declare a conflicting label within the same scope" do
      @scope.label :a_label

      expect{ @scope.label :a_label }.to raise_error ArgumentError
    end

    it "allows a label with the same name as in an outer scope" do
      @scope.label :a_label
      nested_scope = @scope.scope "nested"

      expect{ nested_scope.label :a_label }.to_not raise_error
    end

    it "resolves a label from within a nested scope first" do
      @scope.pc! 0
      @scope.label :a_label
      nested_scope = @scope.scope "nested"
      nested_scope.pc! 1
      nested_scope.label :a_label

      expect(nested_scope.resolve_label :a_label).to eq 1
    end

    it "gives a label block an implicit scope" do
      nested_scope = @scope.label :a_label do end
      expect{ nested_scope.label :a_label }.to_not raise_error
    end

    it "fails to declare a conflicting label from within a macro" do
      @scope.label :a_label
      macro = proc do
        label :a_label
      end
      expect{ @scope.call macro }.to raise_error ArgumentError
    end

    it "allows resolution when executing a macro" do
      @scope.label :a_label
      macro = proc do
        jmp :a_label
      end
      expect{ @scope.call macro }.to_not raise_error
    end

    it "resolves a label from a different segment" do
      @scope.pc! 2
      @scope.label :a_label
      segment_scope = @scope.segment :data
      segment_scope.pc! 3
      expect(segment_scope.resolve_label :a_label).to eq 2
    end

    it "fails to resolve a label from a different segment when not in scope" do
      @scope.pc! 2
      @scope.label :a_label
      segment_scope = @scope.segment :data, scope: :a_different_scope
      segment_scope.pc! 3
      expect{ segment_scope.resolve_label :a_label }.to raise_error ArgumentError
    end

    it "resolves a label from a different segment when just switching segments" do
      @scope.pc! 2
      @scope.label :a_label
      @scope.segment! :data
      @scope.pc! 3
      expect(@scope.resolve_label :a_label).to eq 2
    end

    it "fails to resolve an unqualified label in a nested scope" do
      nested_scope = @scope.scope "nested"
      nested_scope.label :a_label
      expect{ @scope.resolve_label :a_label }.to raise_error ArgumentError
    end

    it "fails to resolve a label from within a macro with explicit scope" do
      macro = proc do
        label :a_label
      end
      @scope.call_with_scope macro, scope: "nested"
      expect{ @scope.resolve_label :a_label }.to raise_error ArgumentError
    end

    it "resolves a label from within a macro executed in scope" do
      @scope.pc! 2
      macro = proc do
        pc! 4
        label :a_label
      end
      @scope.call macro
      expect(@scope.resolve_label :a_label).to eq 4
    end

    it "resolves a fully qualified label in a nested scope" do
      @scope.pc! 1
      inner = @scope.scope "inner"
      inner.pc! 3
      inner.label :label1
      inner_most = inner.scope "most"
      inner_most.pc! 5
      inner_most.label :label1

      expect(@scope.resolve_label :"inner:label1").to eq 3
      expect(@scope.resolve_label :"inner:most:label1").to eq 5
    end

  end

  describe "labels with checkpoint configuration" do
    before do
      @seg = R65::Segment.new :code
      @scope = R65::Scope.new [@seg], @seg
    end

    it "allows a label with a break point" do
      @scope.label :debug, :break
      sym = @seg.as_symbols.first
      expect(sym[:label].checkpoints.first.kind).to eq "break"
    end

    it "allows a label with a conditional break point" do
      @scope.label :debug, :break => "A == $0"
      sym = @seg.as_symbols.first
      expect(sym[:label].checkpoints.first.condition).to eq "A == $0"
    end

    it "fails for an unknown kind of checkpoint" do
      expect{ @scope.label :debug, :unsupported }.to raise_error ArgumentError
    end

    it "allows a label with multiple checkpoints" do
      @scope.label :debug, :break, :watch, :trace
      sym = @seg.as_symbols.first
      expect(sym[:label].checkpoints.map(&:kind)).to eq ["break","watch","trace"]
    end

  end

end
