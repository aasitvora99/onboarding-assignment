require_relative './greed_game'

RSpec.describe 'Greed Game' do
  describe DiceSet do
    it 'rolls the correct number of dice with values from 1 to 6' do
      dice = DiceSet.new
      dice.roll(5)
      expect(dice.values.size).to eq(5)
      expect(dice.values.all? { |v| (1..6).include?(v) }).to be true
    end
  end

  describe '#score' do
    it 'scores three 1s as 1000' do
      expect(score([1, 1, 1, 2, 3])).to eq(1000)
    end

    it 'scores other triples correctly' do
      expect(score([5, 5, 5, 2, 3])).to eq(500)
      expect(score([2, 2, 2, 3, 4])).to eq(200)
    end

    it 'scores single 1s and 5s correctly' do
      expect(score([1, 2, 3, 4, 6])).to eq(100)
      expect(score([5, 2, 3, 4, 6])).to eq(50)
      expect(score([1, 5, 2, 2, 3])).to eq(150)
    end

    it 'returns 0 for a roll with no scoring dice' do
      expect(score([2, 3, 4, 6, 6])).to eq(0)
    end
  end

  describe '#scoring_dice' do
    it 'returns the scoring dice from the roll' do
      expect(scoring_dice([1, 5, 2, 2, 3]).sort).to eq([1, 5])
      expect(scoring_dice([2, 2, 2, 3, 4])).to eq([2, 2, 2])
    end
  end

  describe Player do
    it 'initializes properly with default values' do
      player = Player.new("TestPlayer")
      expect(player.name).to eq("TestPlayer")
      expect(player.total_score).to eq(0)
      expect(player.in_game).to be false
    end
  end
end
