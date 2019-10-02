require_relative "../../lib/r65"

describe R65::SegmentConfig do

  it "configures single segment as is" do
    cfg = R65::SegmentConfig.new do |cfg|
      cfg.define :code, min: 0, start: 1, max: 2, fill: 3
    end
    segs = cfg.to_segments

    expect(segs.size).to eq 1
    seg = segs.first
    expect(seg.min).to eq 0
    expect(seg.start).to eq 1
    expect(seg.max).to eq 2
    expect(seg.fill).to eq 3
  end

  it "configure multiple consecutive segments" do
    cfg = R65::SegmentConfig.new do |cfg|
      cfg.define :first, start: 0, fill: 11
      cfg.define :last, start: 2, max: 3, fill: 22
    end
    first,last = cfg.to_segments.sort_by{|s|s.min}

    expect(first.start).to eq 0
    expect(first.min).to eq first.start
    expect(first.fill).to eq 11
    expect(first.max).to eq last.min

    expect(last.start).to eq 2
    expect(last.min).to eq last.start
    expect(last.max).to eq 3
    expect(last.fill).to eq 22
  end

end
