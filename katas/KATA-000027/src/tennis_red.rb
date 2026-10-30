# frozen_string_literal: true
# SPDX-License-Identifier: MIT
# Intentional behaviorally wrong stub for reproducible RED evidence.
module Tennis
  class InvalidPoint < ArgumentError; end
  class GameOver < StandardError; end
  class Game
    def point(player)
      raise InvalidPoint unless player == 'A' || player == 'B'
      self # wrong: never advances
    end
    def score = 'Love-All'
  end
end
