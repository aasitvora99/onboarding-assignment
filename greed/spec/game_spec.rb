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
    it 'sets up the game with default values' do
      new_game = Greed::Game.new
      expect(new_game.instance_variable_get(:@players)).to eq([])
      expect(new_game.instance_variable_get(:@final_round_started)).to be false
      expect(new_game.instance_variable_get(:@final_round_triggered_by)).to be_nil
    end
  end

  describe '#start' do
    context 'player setup' do
      it 'creates players based on user input' do
        game.instance_variable_set(:@players, [])
        allow(game).to receive(:loop)
        
        game.start
        
        players = game.instance_variable_get(:@players)
        expect(players.length).to eq(2)
        expect(players[0].name).to eq("Player 1")
      end
    end
    
    context 'scoring and game progression' do
      before do
        allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }
      end
      
      it 'handles player scoring scenarios correctly' do
        # Test case 1: Below 300 points
        allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(200)
        allow(Greed::Scoring).to receive(:get_scoring_dice).and_return([5, 5, 5, 5])
        
        game.start
        
        expect(player1.in_game).to be false
        expect(player1.total_score).to eq(0)
        
        # Test case 2: Getting in the game with ≥300 points
        allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(350)
        player1.in_game = false
        
        game.start
        
        expect(player1.in_game).to be true
        expect(player1.total_score).to eq(350)
        
        # Test case 3: Player busting
        allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(0)
        player1.total_score = 500
        
        game.start
        
        expect(player1.total_score).to eq(500) # Score unchanged after bust
      end
      
      it 'triggers final round when threshold is reached' do
        player1.in_game = true
        player1.total_score = 2900
        
        allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(200)
        allow(Greed::Scoring).to receive(:get_scoring_dice).and_return([1, 1])
        
        game.start
        
        expect(player1.total_score).to eq(3100)
        expect(game.instance_variable_get(:@final_round_started)).to be true
        expect(game.instance_variable_get(:@final_round_triggered_by)).to eq(player1)
      end
    end
    
    context 'special game mechanics' do
      it 'allows rolling all dice again when all dice score' do
        player1.in_game = true
        player1.total_score = 1000
        
        first_roll = [1, 1, 5, 5, 5]
        second_roll = [2, 3, 4, 6, 1]
        
        allow(dice_set).to receive(:roll).with(5).and_return(first_roll, second_roll)
        allow(Greed::Scoring).to receive(:calculate_roll_points).and_return(600, 100)
        allow(Greed::Scoring).to receive(:get_scoring_dice).and_return(first_roll, [1])
        allow(game).to receive(:gets).and_return("y\n", "n\n")
        
        allow(game.instance_variable_get(:@players)).to receive(:each) { |&block| block.call(player1) }
        
        game.start
        
        expect(player1.total_score).to eq(1700)
      end
    end
    
    context 'game end conditions' do
      it 'determines the winner correctly' do
        game.instance_variable_set(:@final_round_started, true)
        game.instance_variable_set(:@final_round_triggered_by, player2)
        
        player1.total_score = 3500
        player2.total_score = 3200
        
        expect(game).to receive(:puts).with(/The winner is Player 1 with 3500 points/)
        
        game.start
      end
      
      it 'rotates players during final round' do
        game.instance_variable_set(:@final_round_started, true)
        game.instance_variable_set(:@final_round_triggered_by, player1)
        game.instance_variable_set(:@players, [player1, player2])
        
        expect(game.instance_variable_get(:@players)).to receive(:rotate!)
        
        game.start
      end
    end
  end
end