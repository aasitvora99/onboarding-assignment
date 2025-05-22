module Greed
  module Scoring
    module_function

    def analyze_roll(dice)
      counts = Hash.new(0)
      dice.each { |die| counts[die] += 1 }

      total = 0
      scoring_dice = []

      (1..6).each do |num|
        count = counts[num]

        if count >= 3
          total += num == 1 ? 1000 : num * 100
          3.times { scoring_dice << num }
          count -= 3
        end

        if num == 1 || num == 5
          single_score = num == 1 ? 100 : 50
          total += single_score * count
          scoring_dice.concat([num] * count)
        end
      end

      { score: total, scoring_dice: scoring_dice }
    end
  end
end
