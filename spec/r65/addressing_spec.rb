require_relative "../../lib/r65"

describe R65::Addressing do
  def a_label
    R65::Addressing::LabelExpression.new :label
  end

  def a_label_resolved_to (address)
    a_label.resolve! { address}
  end

  def address_of (value)
    R65::Addressing::ConstantExpression.new 123
  end

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
        expect(R65::Addressing::Expression.from(other)).to eq other
      end

    end

  end

  describe "labels" do
    it "resolves to an address" do
      label = a_label_resolved_to 123

      expect(label.value.to_s).to eq "123"
    end

    it "are nil when unresolved" do
      label = a_label
      expect(label.value).to eq nil
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

        expect(val.pending?).to eq false
        expect(lbl.pending?).to eq true
        expect(exp.pending?).to eq true

        expect(val.value).to eq 123
        expect(lbl.value).to eq nil
        expect(exp.value).to eq nil

        exp.resolve! &lookup

        expect(lbl.pending?).to eq false
        expect(exp.pending?).to eq false
        expect(lbl.value).to eq 456
        expect(exp.value).to eq 579
      end

    end
  end
end
