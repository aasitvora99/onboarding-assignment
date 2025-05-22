require_relative 'spec_helper'

RSpec.describe Greed::Player do
  it 'initializes properly with default values' do
    player = Greed::Player.new("TestPlayer")
    expect(player.name).to eq("TestPlayer")
    expect(player.total_score).to eq(0)
    expect(player.in_game).to be false
  end
end
