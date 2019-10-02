require_relative "../../lib/r65"

describe R65::Program do

  describe "adding data at defined addresses" do
    it "works using pc" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :first, start: 0x00
      end
      prg = R65::Program.new cfg do
        segment! :first
        byte 1
        pc! 0x03
        byte 2
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1, 0, 0, 2]
    end

    it "works using segments" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :first, start: 0x00
        cfg.define :last, start: 0x03
      end
      prg = R65::Program.new cfg do
        segment :last do
          byte 2
        end
        segment! :first
        byte 1
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1, 0, 0, 2]
    end
  end

  describe "space between segments" do

    it "gets filled using previous segment fill byte, if specified" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :first, start: 0, fill: 3
        cfg.define :last, start: 2
      end
      prg = R65::Program.new cfg do
        segment! :first
        byte 1
        segment! :last
        byte 2
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1, 3, 2]
    end

    it "gets filled with 0x00 if previous segement has no fill byte specified" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :first, start: 0
        cfg.define :last, start: 2
      end
      prg = R65::Program.new cfg do
        segment! :first
        byte 1
        segment! :last
        byte 2
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1, 0, 2]
    end

  end

  describe "space before first segment" do

    it "gets filled with 0x00 if no fill byte is specified" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :first, min: 0, start: 1
        cfg.define :last, start: 2
      end
      prg = R65::Program.new cfg do
        segment! :first
        byte 1
        segment! :last
        byte 2
      end

      expect(prg.as_bytes(skip_header: true)).to eq [0, 1, 2]
    end

    it "gets filled using specified fill byte" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :first, min: 0, start: 1, fill: 3
        cfg.define :last, start: 2
      end
      prg = R65::Program.new cfg do
        segment! :first
        byte 1
        segment! :last
        byte 2
      end

      expect(prg.as_bytes(skip_header: true)).to eq [3, 1, 2]
    end

  end

  describe "space after last instruction in the last segment" do

    it "doesn't get filled if no fill byte is specified" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :code, start: 0, max: 2
      end
      prg = R65::Program.new cfg do
        byte 1
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1]
    end

    it "doesn't get filled if no max address is specified" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :code, start: 0, fill: 3
      end
      prg = R65::Program.new cfg do
        byte 1
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1]
    end

    it "gets filled using specified fill byte if max is set" do
      cfg = R65::SegmentConfig.new do |cfg|
        cfg.define :code, start: 0, max: 2, fill: 3
      end
      prg = R65::Program.new cfg do
        byte 1
      end

      expect(prg.as_bytes(skip_header: true)).to eq [1, 3]
    end

  end

end
