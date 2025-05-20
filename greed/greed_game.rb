class DiceSet
  def roll(num)
    Array.new(num) { rand(1..6) }
  end
end

def calculate_roll_points(dice)
  counts = Hash.new(0)
  dice.each { |die| counts[die] += 1 }

  total = 0

  (1..6).each do |num|
    if counts[num] >= 3
      total += num == 1 ? 1000 : num * 100
      counts[num] -= 3
    end
  end

  total += counts[1] * 100
  total += counts[5] * 50
  total
end

def get_scoring_dice(dice)
  counts = Hash.new(0)
  dice.each { |die| counts[die] += 1 }

  scoring = []

  (1..6).each do |num|
    if counts[num] >= 3
      3.times { scoring << num }
      counts[num] -= 3
    end
  end

  scoring += [1] * counts[1]
  scoring += [5] * counts[5]

  scoring
end

class Player
  attr_accessor :name, :total_score, :in_game

  def initialize(name)
    @name = name
    @total_score = 0
    @in_game = false
  end
end

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
          roll_score = calculate_roll_points(roll)
          if roll_score == 0
            puts "Score in this round: 0 (bust)"
            turn_score = 0
            break
          end

          turn_score += roll_score
          scoring = get_scoring_dice(roll)
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
    puts "\n🏆 The winner is #{winner.name} with #{winner.total_score} points!"
  end
end

if __FILE__ == $0
  Game.new.start
end
