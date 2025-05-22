module Greed
  class Player
    attr_accessor :name, :total_score, :in_game

    def initialize(name)
      @name = name
      @total_score = 0
      @in_game = false
    end
  end
end
