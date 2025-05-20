module Greed
  module Scoring
    module_function

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
  end
end