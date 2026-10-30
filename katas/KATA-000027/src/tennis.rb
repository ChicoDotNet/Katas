# frozen_string_literal: true
# SPDX-License-Identifier: MIT

module Tennis
  class InvalidPoint < ArgumentError; end
  class GameOver < StandardError; end

  # Immutable, bounded tennis-game automaton. Deuce and advantage never
  # require an unbounded counter; each accepted point returns a new Game.
  class Game
    WORDS = %w[Love Fifteen Thirty Forty].freeze
    attr_reader :phase

    def initialize(phase = :opening, a = 0, b = 0)
      valid = case phase
              when :opening then (0..3).cover?(a) && (0..3).cover?(b) && !(a == 3 && b == 3)
              when :deuce, :adv_a, :adv_b, :won_a, :won_b then a.zero? && b.zero?
              else false
              end
      raise ArgumentError, 'invalid game state' unless valid

      @phase = phase
      @a = a
      @b = b
      freeze
    end

    def point(player)
      raise GameOver, 'game already finished' if @phase == :won_a || @phase == :won_b
      raise InvalidPoint, 'player must be A or B' unless player == 'A' || player == 'B'

      case @phase
      when :opening
        a = @a + (player == 'A' ? 1 : 0)
        b = @b + (player == 'B' ? 1 : 0)
        return self.class.new(:won_a) if a == 4
        return self.class.new(:won_b) if b == 4
        return self.class.new(:deuce) if a == 3 && b == 3

        self.class.new(:opening, a, b)
      when :deuce
        self.class.new(player == 'A' ? :adv_a : :adv_b)
      when :adv_a
        self.class.new(player == 'A' ? :won_a : :deuce)
      when :adv_b
        self.class.new(player == 'B' ? :won_b : :deuce)
      end
    end

    def score
      case @phase
      when :opening
        return "#{WORDS.fetch(@a)}-All" if @a == @b

        "#{WORDS.fetch(@a)}-#{WORDS.fetch(@b)}"
      when :deuce then 'Deuce'
      when :adv_a then 'Advantage A'
      when :adv_b then 'Advantage B'
      when :won_a then 'Win A'
      when :won_b then 'Win B'
      end
    end
  end
end
