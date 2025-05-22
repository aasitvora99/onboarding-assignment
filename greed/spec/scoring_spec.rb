require_relative 'spec_helper'

RSpec.describe Greed::Scoring do
  describe '.analyze_roll' do
    it 'scores three 1s as 1000' do
      result = Greed::Scoring.analyze_roll([1, 1, 1, 2, 3])
      expect(result[:score]).to eq(1000)
      expect(result[:scoring_dice].sort).to eq([1, 1, 1])
    end

    it 'scores other triples correctly' do
      result = Greed::Scoring.analyze_roll([5, 5, 5, 2, 3])
      expect(result[:score]).to eq(500)
      expect(result[:scoring_dice].sort).to eq([5, 5, 5])

      result = Greed::Scoring.analyze_roll([2, 2, 2, 3, 4])
      expect(result[:score]).to eq(200)
      expect(result[:scoring_dice].sort).to eq([2, 2, 2])
    end

    it 'scores single 1s and 5s correctly' do
      result = Greed::Scoring.analyze_roll([1, 2, 3, 4, 6])
      expect(result[:score]).to eq(100)
      expect(result[:scoring_dice]).to eq([1])

      result = Greed::Scoring.analyze_roll([5, 2, 3, 4, 6])
      expect(result[:score]).to eq(50)
      expect(result[:scoring_dice]).to eq([5])

      result = Greed::Scoring.analyze_roll([1, 5, 2, 2, 3])
      expect(result[:score]).to eq(150)
      expect(result[:scoring_dice].sort).to eq([1, 5])
    end

    it 'returns 0 for a roll with no scoring dice' do
      result = Greed::Scoring.analyze_roll([2, 3, 4, 6, 6])
      expect(result[:score]).to eq(0)
      expect(result[:scoring_dice]).to eq([])
    end
  end
end
