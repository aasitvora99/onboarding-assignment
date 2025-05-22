module Greed
  class DiceSet
    attr_reader :values

    def roll(num)
      @values = Array.new(num) { rand(1..6) }
    end
  end
end
