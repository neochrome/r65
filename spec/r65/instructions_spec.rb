require_relative "../../lib/r65"

describe R65::Label::Checkpoint do

  it "allows a label with a break point" do
    points = R65::Label::Checkpoint.from :break
    expect(points.first.kind).to eq "break"
  end

  it "allows a label with a conditional break point" do
    points = R65::Label::Checkpoint.from :break => "A == $0"
    expect(points.first.kind).to eq "break"
    expect(points.first.condition).to eq "A == $0"
  end

  it "allows a label with a trace point" do
    points = R65::Label::Checkpoint.from :trace
    expect(points.first.kind).to eq "trace"
  end

  it "allows a label with a conditional trace point" do
    points = R65::Label::Checkpoint.from :trace => "A == $1"
    expect(points.first.kind).to eq "trace"
    expect(points.first.condition).to eq "A == $1"
  end

  it "allows a label with a watch point" do
    points = R65::Label::Checkpoint.from :watch
    expect(points.first.kind).to eq "watch"
  end

  it "allows a label with a conditional watch point" do
    points = R65::Label::Checkpoint.from :watch => "A == $2"
    expect(points.first.kind).to eq "watch"
    expect(points.first.condition).to eq "A == $2"
  end

  it "fails for an unknown kind of checkpoint" do
    expect{ R65::Label::Checkpoint.from :unsupported }.to raise_error ArgumentError
  end

end
