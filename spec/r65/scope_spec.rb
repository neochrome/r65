require_relative "../../lib/r65"

describe R65::Scope do

  describe "#align" do

    it "can align pc, v1" do
      seg = R65::Segment.new :code
      scope = R65::Scope.new [seg], seg

      scope.pc! 0x10f0
      scope.align! 0x100

      expect(seg.pc).to eq 0x1100
    end

    it "can align pc, v2" do
      seg = R65::Segment.new :code
      scope = R65::Scope.new [seg], seg

      scope.pc! 0xf0
      scope.align! 0x1000

      expect(seg.pc).to eq 0x1000
    end

    it "fails if alignment is negative" do
      seg = R65::Segment.new :code
      scope = R65::Scope.new [seg], seg
      expect{ scope.align! -1 }.to raise_error RangeError
    end

    it "fails if alignment is not power of 2" do
      seg = R65::Segment.new :code
      scope = R65::Scope.new [seg], seg
      expect{ scope.align! 3 }.to raise_error ArgumentError
    end

  end

end
