require_relative "../../lib/r65"
require_relative "../../lib/c64"

describe C64::ZeroPage do

  describe "when created" do
    it "has defaults" do
      zp = C64::ZeroPage.new

      expect(zp.any?).to eq false
      expect(zp.pc).to eq 0x02
    end

    it "does not contain a label" do
      zp = C64::ZeroPage.new

      expect(zp.has? :label).to eq false
      expect{ zp[:label] }.to raise_error KeyError
    end
  end

  describe "when registering a byte" do
    it "increases the pc by one" do
      zp = C64::ZeroPage.new
      pc = zp.pc
      zp.byte :a_byte

      expect(zp.pc).to eq pc+1
    end

    it "is remembered" do
      zp = C64::ZeroPage.new.byte :a_byte

      expect(zp.any?).to eq true
      expect(zp.has? :a_byte).to eq true
    end

    it "is assigned at the current pc" do
      zp = C64::ZeroPage.new
      pc = zp.pc
      zp.byte :a_byte

      expect(zp[:a_byte]).to eq pc
    end

    it "fails if label is already registered" do
      zp = C64::ZeroPage.new.byte :a_byte

      expect{ zp.byte :a_byte}.to raise_error KeyError
    end

    it "fails unless the byte fits below pc 0xff" do
      zp = C64::ZeroPage.new
      (0xff - zp.pc).times do |a|
        zp.byte :"label_#{a}"
      end

      expect{ zp.byte :a_byte }.to raise_error RangeError
    end
  end

  describe "when registering multiple bytes" do
    it "increases the pc by the number of bytes" do
      zp = C64::ZeroPage.new
      pc = zp.pc
      zp.bytes :a_byte, 3

      expect(zp.pc).to eq pc+3
    end

    it "is remembered" do
      zp = C64::ZeroPage.new.byte :a_byte

      expect(zp.any?).to eq true
      expect(zp.has? :a_byte).to eq true
    end

    it "is assigned at the current pc" do
      zp = C64::ZeroPage.new
      pc = zp.pc
      zp.byte :a_byte

      expect(zp[:a_byte]).to eq pc
    end

    it "fails if label is already registered" do
      zp = C64::ZeroPage.new.byte :a_byte

      expect{ zp.byte :a_byte}.to raise_error KeyError
    end

    it "fails unless all the bytes fits below pc 0xff" do
      zp = C64::ZeroPage.new
      zp.bytes :lotsa, 0xff - zp.pc - 2

      expect{ zp.bytes :some_more, 3 }.to raise_error RangeError
    end
  end

  describe "when registering a word" do
    it "increases the pc by two" do
      zp = C64::ZeroPage.new
      pc = zp.pc
      zp.word :a_word

      expect(zp.pc).to eq pc+2
    end

    it "is remembered" do
      zp = C64::ZeroPage.new.word :a_word

      expect(zp.any?).to eq true
      expect(zp.has? :a_word).to eq true
    end

    it "is assigned at the current pc" do
      zp = C64::ZeroPage.new
      pc = zp.pc
      zp.word :a_word

      expect(zp[:a_word]).to eq pc
    end

    it "fails if label is already registered" do
      zp = C64::ZeroPage.new.word :a_word

      expect{ zp.word :a_word}.to raise_error KeyError
    end

    it "fails unless the word fits below pc 0xff" do
      zp = C64::ZeroPage.new
      (0xff - zp.pc - 1).times do |a|
        zp.byte :"label_#{a}"
      end

      expect{ zp.word :a_word }.to raise_error RangeError
    end
  end

end
