require_relative "../../lib/extensions/integer.rb"

describe "Integer Extensions" do
  class Integer
    prepend IntegerExtensions
  end

  describe "unary not operator" do
    [
      [0b00111100, 0b11000011],
      [0b11000011, 0b00111100],
      [0b00001111, 0b11110000],
      [0b00000001, 0b11111110],
      [0b11111110, 0b00000001],
    ].each do |value, expected|
      it "works" do
        expect(!value).to eq expected
      end
    end
  end

end
