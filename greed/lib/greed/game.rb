require_relative 'dice_set'
require_relative 'player'
require_relative 'scoring'

module Greed
  class Game
    FINAL_SCORE = 3000

    def initialize
      @players = []
      @dice_set = DiceSet.new
      @final_round_started = false
      @final_round_triggered_by = nil
    end

    def start
      puts "Enter number of players:"
      num = gets.to_i
      num.times do |i|
        @players << Player.new("Player #{i + 1}")
      end

      turn = 1
      loop do
        puts "\nTurn #{turn}:"

        @players.each do |player|
          puts "\n#{player.name}'s turn:"
          turn_score = 0
          remaining_dice = 5
          continue = true

          while continue
            roll = @dice_set.roll(remaining_dice)
            puts "#{player.name} rolls: #{roll.join(', ')}"
            roll_score = Scoring.calculate_roll_points(roll)
            if roll_score == 0
              puts "Score in this round: 0 (bust)"
              turn_score = 0
              break
            end

            turn_score += roll_score
            scoring = Scoring.get_scoring_dice(roll)
            remaining_dice = roll.length - scoring.length

            puts "Score in this round: #{turn_score}"
            puts "Total score: #{player.total_score}"

            if remaining_dice == 0
              remaining_dice = 5
              puts "All dice scored! You get to roll all 5 again."
              next
            end

            puts "Do you want to roll the non-scoring #{remaining_dice} dice? (y/n):"
            continue = gets.chomp.downcase == 'y'
          end

          if !player.in_game && turn_score >= 300
              player.in_game = true
              player.total_score += turn_score
          elsif player.in_game
            player.total_score += turn_score
          else
            puts "#{player.name} needs at least 300 points in one turn to start scoring."
          end

          puts "#{player.name}'s Total Score: #{player.total_score}"

          if player.total_score >= FINAL_SCORE && !@final_round_started
            @final_round_triggered_by = player
            @final_round_started = true
            puts "\n#{player.name} has reached #{FINAL_SCORE} points! Final round begins..."
          end
        end

        if @final_round_started
          if @players.last == @final_round_triggered_by
            break
          else
            @players.rotate!
          end
        end

        turn += 1
      end

      winner = @players.max_by(&:total_score)
      puts "\nThe winner is #{winner.name} with #{winner.total_score} points!"
    end
  end
end