# frozen_string_literal: true
require 'minitest/autorun'
module TripKata
  class TripService
    def trips_for(_target_id)
      [] # intentionally wrong behavioral stub, still syntactically valid
    end
  end
end
class RedTripTest < Minitest::Test
  def test_friend_receives_trips
    assert_equal ['trip-1'], TripKata::TripService.new.trips_for('target')
  end
end
