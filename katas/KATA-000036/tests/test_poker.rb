# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'minitest/autorun'
require_relative '../src/poker'
class PokerTest < Minitest::Test
 def choose(*hands);NinjaPoker.best(hands);end
 def test_straight_flush_beats_quads
  assert_equal ['9H TH JH QH KH'],choose('9H TH JH QH KH','AS AD AH AC 3D')
 end
 def test_wheel_straight_lower_than_six_high
  assert_equal ['2C 3S 4D 5H 6C'],choose('AS 2D 3C 4H 5D','2C 3S 4D 5H 6C')
 end
 def test_wheel_straight_flush
  assert_equal ['AH 2H 3H 4H 5H'],choose('AH 2H 3H 4H 5H','AS KD QH JC 9S')
 end
 def test_four_of_a_kind_kicker
  assert_equal ['AC AD AH AS KC'],choose('AC AD AH AS KC','AC AD AH AS QC')
 end
 def test_full_house_beats_flush
  assert_equal ['2C 2D 2H 3S 3C'],choose('2C 2D 2H 3S 3C','2S 5S 7S JS KS')
 end
 def test_flush_beats_straight
  assert_equal ['2H 4H 6H 8H TH'],choose('2H 4H 6H 8H TH','3C 4D 5H 6S 7D')
 end
 def test_two_pair_high_then_low_then_kicker
  assert_equal ['KH KD 4D 4C AS'],choose('KH KD 4D 4C AS','QH QD JC JS AH')
 end
 def test_full_house_trip_value
  assert_equal ['6H 6D 6C 2H 2D'],choose('5H 5D 5C AH AD','6H 6D 6C 2H 2D')
 end
 def test_identical_rank_ties_preserve_input_order
  assert_equal ['AH KH QH JH TH','AS KS QS JS TS'],choose('AH KH QH JH TH','AS KS QS JS TS','9H TH JH QH KH')
 end
 def test_pair_kickers
  assert_equal ['AC AD KH QS 8C'],choose('AC AD KH QS 8C','AS AH KC QD 7H')
 end
 def test_empty;assert_empty NinjaPoker.best([]);end
 def test_invalid_cards_and_duplicate
  assert_raises(ArgumentError){choose('AS AS KD QC 2H')}
  assert_raises(ArgumentError){choose('AS KD QC 2H')}
  assert_raises(ArgumentError){choose('XS KD QC 2H 3C')}
 end
end
