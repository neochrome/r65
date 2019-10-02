require_relative "../../lib/r65"

describe R65::Addressing do

  describe R65::Addressing::Expression do

    describe "conversion from" do

      example "symbol" do
        expect(R65::Addressing::Expression.from(:label)).to be_an_instance_of R65::Addressing::LabelExpression
      end

      example "integers" do
        expect(R65::Addressing::Expression.from(123)).to be_an_instance_of R65::Addressing::ConstantExpression
      end

      example "other expressions" do
        other = R65::Addressing::Expression.from 456
        expect(R65::Addressing::Expression.from(other)).to be other
      end

    end
  end

  describe "math" do

    describe "basics" do

      it "works" do
        val = R65::Addressing::ConstantExpression.new 123
        lbl = R65::Addressing::LabelExpression.new :label
        exp = R65::Addressing::BinaryExpression.new lbl, val, :+
        lookup = proc do |label|
          456
        end

        expect(val.pending?).to be false
        expect(lbl.pending?).to be true
        expect(exp.pending?).to be true

        expect(val.value).to be 123
        expect(lbl.value).to be nil
        expect(exp.value).to be nil

        exp.resolve! &lookup

        expect(lbl.pending?).to be false
        expect(exp.pending?).to be false
        expect(lbl.value).to be 456
        expect(exp.value).to be 579
      end

    end
  end
end
