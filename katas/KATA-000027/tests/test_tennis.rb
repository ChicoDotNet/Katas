# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'minitest/autorun'
require ENV.fetch('TENNIS_IMPL', 'tennis')

class TennisGameTest < Minitest::Test
  def replay(seq)
    seq.chars.reduce(Tennis::Game.new) { |game, p| game.point(p) }
  end

  def test_initial_score
    assert_equal 'Love-All', replay('').score
  end

  def test_opening_scores
    { 'A' => 'Fifteen-Love', 'B' => 'Love-Fifteen', 'AA' => 'Thirty-Love',
      'AAA' => 'Forty-Love', 'AB' => 'Fifteen-All', 'AABB' => 'Thirty-All',
      'AAABB' => 'Forty-Thirty', 'AABBB' => 'Thirty-Forty' }.each do |seq, expected|
      assert_equal expected, replay(seq).score, seq
    end
  end

  def test_direct_wins
    assert_equal 'Win A', replay('AAAA').score
    assert_equal 'Win B', replay('BBBB').score
    assert_equal 'Win A', replay('AAABBA').score
    assert_equal 'Win B', replay('BBAABB').score
  end

  def test_deuce_and_advantage_cycle
    assert_equal 'Deuce', replay('AAABBB').score
    assert_equal 'Advantage A', replay('AAABBBA').score
    assert_equal 'Advantage B', replay('AAABBBB').score
    assert_equal 'Deuce', replay('AAABBBAB').score
    assert_equal 'Deuce', replay('AAABBBBA').score
    assert_equal 'Win A', replay('AAABBBAA').score
    assert_equal 'Win B', replay('AAABBBBB').score
  end

  def test_terminal_point_is_rejected
    assert_raises(Tennis::GameOver) { replay('AAAA').point('A') }
    assert_raises(Tennis::GameOver) { replay('AAAA').point('Z') }
    assert_raises(Tennis::GameOver) { replay('AAABBBAA').point('B') }
  end

  def test_invalid_player_never_mutates
    game = replay('AAB')
    assert_raises(Tennis::InvalidPoint) { game.point('C') }
    assert_equal 'Thirty-Fifteen', game.score
  end

  def test_immutable_snapshots
    before = replay('AAB')
    after = before.point('B')
    assert_equal 'Thirty-Fifteen', before.score
    assert_equal 'Thirty-All', after.score
    refute_same before, after
    assert before.frozen?
    assert after.frozen?
  end

  def test_invalid_construction_rejected
    assert_raises(ArgumentError) { Tennis::Game.new(:opening, 3, 3) }
    assert_raises(ArgumentError) { Tennis::Game.new(:opening, 4, 0) }
    assert_raises(ArgumentError) { Tennis::Game.new(:adv_a, 1, 0) }
  end
end
