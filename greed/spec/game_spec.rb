require_relative 'spec_helper'

RSpec.describe Greed::Game do
  let(:game) { Greed::Game.new }
  let(:dice_set) { instance_double(Greed::DiceSet) }
  let(:player1) { Greed::Player.new("Player 1") }
  let(:player2) { Greed::Player.new("Player 2") }

  before do
    allow(Greed::DiceSet).to receive(:new).and_return(dice_set)
    allow(dice_set).to receive(:roll).and_return([1, 2, 3, 4, 5])
    allow(game).to receive(:gets).and_return("2\n", "n\n")
    allow(game).to receive(:puts)
    allow(game).to receive(:loop) { |&block| block.call }

    game.instance_variable_set(:@players, [player1, player2])
  end

  describe '#initialize' do
    it 'sets up the game correctly' do
      new_game = Greed::Game.new
      expect(new_game.instance_variable_get(:@players)).to eq([])
      expect(new_game.instance_variable_get(:@final_round_started)).to be false
      expect(new_game.instance_variable_get(:@final_round_triggered_by)).to be_nil
    end
  end

  describe '#start' do
    it 'creates players if none exist' do
      game.instance_variable_set(:@players, [])

      allow(game).to receive(:loop)

      game.start

      players = game.instance_variable_get(:@players)
      expect(players.length).to eq(2)
      expect(players[0].name).to eq("Player 1")
    end

    it 'handles a player scoring below 300 points' do
      allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(200)
      allow(Greed::Scoring).to receive(:get_scoring_dice).and_return([5, 5, 5, 5])

      allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }

      game.start

      expect(player1.in_game).to be false
      expect(player1.total_score).to eq(0)
    end

    it 'handles a player getting in the game with ≥300 points' do
      allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(350)
      allow(Greed::Scoring).to receive(:get_scoring_dice).and_return([1, 1, 1, 5])

      allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }

      game.start

      expect(player1.in_game).to be true
      expect(player1.total_score).to eq(350)
    end

    it 'handles a player busting' do
      allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(0)
      allow(Greed::Scoring).to receive(:get_scoring_dice).and_return([])

      player1.in_game = true
      player1.total_score = 500

      allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }

      game.start

      expect(player1.total_score).to eq(500)
    end

    it 'triggers final round when a player reaches the final score' do
      player1.in_game = true
      player1.total_score = 2900

      allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(200)
      allow(Greed::Scoring).to receive(:get_scoring_dice).and_return([1, 1])

      allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }

      game.start

      expect(player1.total_score).to eq(3100)
      expect(game.instance_variable_get(:@final_round_started)).to be true
      expect(game.instance_variable_get(:@final_round_triggered_by)).to eq(player1)
    end

    it 'determines the winner when the game ends' do
      game.instance_variable_set(:@final_round_started, true)
      game.instance_variable_set(:@final_round_triggered_by, player2)

      player1.total_score = 3500
      player2.total_score = 3200

      expect(game).to receive(:puts).with(/The winner is Player 1 with 3500 points/)

      game.start
    end

    it 'allows rolling all 5 dice again when all dice score' do
      continue_values = [true, false]
      continue_iterator = continue_values.each

      player1.in_game = true
      player1.total_score = 1000

      first_roll = [1, 1, 5, 5, 5]
      second_roll = [2, 3, 4, 6, 1]

      expect(dice_set).to receive(:roll).with(5).and_return(first_roll, second_roll)

      allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(600, 100)
      allow(Greed::Scoring).to receive(:get_scoring_dice).and_return(first_roll, [1])

      allow(game).to receive(:gets) { continue_iterator.next ? "y\n" : "n\n" }

      allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }

      game.start

      expect(player1.total_score).to eq(1700)
    end

    it 'rotates players when final round continues' do
      game.instance_variable_set(:@final_round_started, true)
      game.instance_variable_set(:@final_round_triggered_by, player1)
      game.instance_variable_set(:@players, [player1, player2])

      expect(game.instance_variable_get(:@players)).to receive(:rotate!)

      game.start
    end
  end
end
