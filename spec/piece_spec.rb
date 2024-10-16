require_relative "../lib/piece"

describe Pawn do

  describe "#disable_double_step" do
    context "when being call" do
      subject(:test_pawn) { described_class.new('W') }
      it("it move_type shall exclude double step") do    
        test_pawn.disable_double_step()
        expect(test_pawn.move_type.include?("two-step-vertical-up")).to eql(false)
      end
    end
  end

  describe "#add_en_passant" do
    context "when being call" do
      subject(:test_pawn) { described_class.new('B') }
      it("it move_type shall include one-step-diagonal") do    
        test_pawn.add_en_passant({})
        expect(test_pawn.move_type.include?("one-step-diagonal-down")).to eql(true)
      end
    end
  end

  describe "#delete_en_passant" do
    context "when being call" do
      subject(:test_pawn) { described_class.new('B') }
      it("it move_type shall exclude one-step-diagonal") do    
        test_pawn.delete_en_passant()
        expect(test_pawn.move_type.include?("one-step-diagonal-down")).to eql(false)
      end
    end
  end
end