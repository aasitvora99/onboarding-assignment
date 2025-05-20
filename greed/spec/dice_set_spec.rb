require_relative 'spec_helper'

RSpec.describe Greed::DiceSet do
  it 'rolls the correct number of dice with values from 1 to 6' do
    dice = Greed::DiceSet.new
    dice.roll(5)
    expect(dice.values.size).to eq(5)
    expect(dice.values.all? { |v| (1..6).include?(v) }).to be true
  end
end