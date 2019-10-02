require_relative "../../lib/r65"

describe R65::Segment do

  context "when created" do

    it "has defaults" do
      seg = R65::Segment.new :code
      expect(seg.min).to eq 0x0000
      expect(seg.start).to eq seg.min
      expect(seg.pc).to eq seg.start
    end

    it "fails if min is greater than max" do
      expect{ R65::Segment.new :data, min: 1, max: 0 }.to raise_error RangeError
    end

    it "fails if min or max is outside 0x0000 - 0xffff" do
      expect{ R65::Segment.new :data, min: -1 }.to raise_error RangeError
      expect{ R65::Segment.new :data, min: 0x10000 }.to raise_error RangeError
      expect{ R65::Segment.new :data, max: -1 }.to raise_error RangeError
      expect{ R65::Segment.new :data, max: 0x10000 }.to raise_error RangeError
    end

    it "fails if start is greater than max" do
      expect{ R65::Segment.new :test, min: 0, max: 1, start: 2 }.to raise_error RangeError
    end

    it "fails if start is lower than min" do
      expect{ R65::Segment.new :test, min: 1, max: 2, start: 0 }.to raise_error RangeError
    end

    it "accepts a start equal to min" do
      expect(R65::Segment.new(:test, min: 1, max: 2, start: 1)).to be_an_instance_of R65::Segment
    end

    it "accepts a start equal to max" do
      expect(R65::Segment.new(:test, min: 1, max: 2, start: 2)).to be_an_instance_of R65::Segment
    end

  end

  context "when set to be filled" do

    context "and have max set" do

      it "fills the whole range" do
        seg = R65::Segment.new :test, min: 0, max: 3, fill: 3
        expect(seg.as_bytes).to eq [3,3,3]
      end

      it "fills to the end" do
        seg = R65::Segment.new :test, min: 0, max: 3, fill: 3
        seg.add R65::Data.new 1
        expect(seg.as_bytes).to eq [1,3,3]
      end

      it "fills in the beginning" do
        seg = R65::Segment.new :test, min: 0, max: 3, fill: 3
        seg.pc! 2
        seg.add R65::Data.new 1
        expect(seg.as_bytes).to eq [3,3,1]
      end

      it "fills around, with respect to start" do
        seg = R65::Segment.new :test, min: 0, max: 3, start: 1, fill: 3
        seg.add R65::Data.new 1
        expect(seg.as_bytes).to eq [3,1,3]
      end

    end

  end

  context "when setting pc" do

    it "fails when new pc higher than max" do
      seg = R65::Segment.new :test, min: 0, max: 3
      seg.pc! 3
      expect{ seg.pc! 4 }.to raise_error RangeError
    end

    it "fails when new pc is lower than current" do
      seg = R65::Segment.new :test, min: 0, start: 1, max: 3
      expect{ seg.pc! 0 }.to raise_error RangeError
    end

    context "and not set to fill" do

      it "just moves pc when no previous instructions" do
        seg = R65::Segment.new :test, min: 0, max: 3
        seg.pc! 2
        seg.add R65::Data.new 1
        expect(seg.as_bytes).to eq [1]
      end

      it "just fill with 0x00 if there are previous instructions" do
        seg = R65::Segment.new :test, min: 0, max: 3
        seg.add R65::Data.new 1
        seg.pc! 2
        seg.add R65::Data.new 2
        expect(seg.as_bytes).to eq [1,0,2]
      end

    end

  end

  context "adding instructions" do

    context "when current pc is at max" do

      it "accepts a byte-sized instruction" do
        seg = R65::Segment.new :test, min: 0, max: 1, start: 1
        expect{ seg.add R65::Data.new 1 }.to_not raise_error
      end

      it "fails when the instruction is bigger than one byte" do
        seg = R65::Segment.new :test, min: 0, max: 1, start: 1
        seg.add R65::Data.new 1
        expect{ seg.add R65::Data.new 2 }.to raise_error RangeError
      end

    end

  end

  context "when asked to be filled" do

    it "fills to the end (max), with specified fill byte" do
      seg = R65::Segment.new :test, min: 0, max: 2, fill: 3
      seg.add R65::Data.new 1
      expect(seg.as_bytes(fill_after: true)).to eq [1, 3]
    end

    it "fills to the end (max), with 0x00 if no fill byte specified" do
      seg = R65::Segment.new :test, min: 0, max: 2
      seg.add R65::Data.new 1
      expect(seg.as_bytes(fill_after: true)).to eq [1, 0]
    end

    it "fills from the beginning (min), with specified fill byte" do
      seg = R65::Segment.new :test, min: 0, max: 2, fill: 3
      seg.pc! 1
      seg.add R65::Data.new 1
      expect(seg.as_bytes(fill_before: true)).to eq [3, 1]
    end

    it "fills from the beginning (min), with 0x00 if no fill byte specified" do
      seg = R65::Segment.new :test, min: 0, max: 2
      seg.pc! 1
      seg.add R65::Data.new 1
      expect(seg.as_bytes(fill_before: true)).to eq [0, 1]
    end

    it "works as in KickAssembler example" do
      seg = R65::Segment.new :example, min: 0x1000, max: 0x1008, fill: 0
      seg.pc! 0x1002
      seg.add R65::Data.new 1
      seg.add R65::Data.new 2
      seg.add R65::Data.new 3
      expect(seg.as_bytes).to eq [0,0,1,2,3,0,0,0]
    end

  end

  context "assembling" do

    it "is idempotent" do
      seg = R65::Segment.new :test, min: 0, max: 2, fill: 3
      seg.add R65::Data.new 1
      seg.assemble!
      bytes1 = seg.as_bytes
      seg.assemble!
      bytes2 = seg.as_bytes
      expect(bytes2).to eq bytes1
    end

  end

end
