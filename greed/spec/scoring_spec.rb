require_relative 'spec_helper'

RSpec.describe Greed::Scoring do
  describe '.calculate_roll_points' do
    it 'scores three 1s as 1000' do
      expect(Greed::Scoring.calculate_roll_points([1, 1, 1, 2, 3])).to eq(1000)
    end

    it 'scores other triples correctly' do
      expect(Greed::Scoring.calculate_roll_points([5, 5, 5, 2, 3])).to eq(500)
      expect(Greed::Scoring.calculate_roll_points([2, 2, 2, 3, 4])).to eq(200)
    end

    it 'scores single 1s and 5s correctly' do
      expect(Greed::Scoring.calculate_roll_points([1, 2, 3, 4, 6])).to eq(100)
      expect(Greed::Scoring.calculate_roll_points([5, 2, 3, 4, 6])).to eq(50)
      expect(Greed::Scoring.calculate_roll_points([1, 5, 2, 2, 3])).to eq(150)
    end

    it 'returns 0 for a roll with no scoring dice' do
      expect(Greed::Scoring.calculate_roll_points([2, 3, 4, 6, 6])).to eq(0)
    end
  end

  describe '.get_scoring_dice' do
    it 'returns the scoring dice from the roll' do
      expect(Greed::Scoring.get_scoring_dice([1, 5, 2, 2, 3]).sort).to eq([1, 5])
      expect(Greed::Scoring.get_scoring_dice([2, 2, 2, 3, 4])).to eq([2, 2, 2])
    end
  end
end