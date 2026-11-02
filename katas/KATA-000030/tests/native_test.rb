# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../src/trip_service'

class TripServiceTest < Minitest::Test
  def user(id: 'target', friends: ['alice'], trips: ['trip-1', 'trip-2'])
    TripKata::User.new(id: id, friend_ids: friends, trip_ids: trips)
  end

  def service(viewer, users = [user])
    TripKata::TripService.new(directory: TripKata::UserDirectory.new(users), session: TripKata::Session.new(viewer))
  end

  def test_login_required_even_when_target_missing
    error = assert_raises(TripKata::RequestError) { service(nil).trips_for('missing') }
    assert_equal 'not_logged_in', error.code
  end

  def test_target_missing
    error = assert_raises(TripKata::RequestError) { service('alice').trips_for('missing') }
    assert_equal 'user_not_found', error.code
  end

  def test_friend_can_see_trips_in_original_order
    assert_equal %w[trip-1 trip-2], service('alice').trips_for('target')
  end

  def test_stranger_cannot_see_trips
    assert_empty service('stranger').trips_for('target')
  end

  def test_owner_can_see_own_trips
    assert_equal %w[trip-1 trip-2], service('target', [user(friends: [])]).trips_for('target')
  end

  def test_exact_identifier_comparison
    assert_empty service('alice2').trips_for('target')
  end

  def test_duplicate_friendships_do_not_duplicate_trips
    assert_equal %w[trip-1 trip-2], service('alice', [user(friends: %w[alice alice])]).trips_for('target')
  end

  def test_duplicate_trips_preserved
    assert_equal %w[trip-1 trip-1], service('alice', [user(trips: %w[trip-1 trip-1])]).trips_for('target')
  end

  def test_output_does_not_expose_mutable_repository_storage
    target = user
    got = service('alice', [target]).trips_for('target')
    got << 'injected'
    assert_equal %w[trip-1 trip-2], target.trip_ids
  end

  def test_contract_rejects_duplicate_user_identifiers
    request = { 'viewer' => 'alice', 'target' => 'target', 'users' => [entry, entry] }
    assert_equal({ 'error' => 'invalid_request' }, TripKata::Contract.execute(request))
  end

  def test_contract_rejects_unknown_fields
    request = { 'viewer' => 'alice', 'target' => 'target', 'users' => [entry], 'admin' => true }
    assert_equal({ 'error' => 'invalid_request' }, TripKata::Contract.execute(request))
  end

  def test_contract_rejects_non_string_friend
    request = { 'viewer' => 'alice', 'target' => 'target', 'users' => [entry.merge('friends' => [42])] }
    assert_equal({ 'error' => 'invalid_request' }, TripKata::Contract.execute(request))
  end

  def test_contract_rejects_empty_identifier
    request = { 'viewer' => '', 'target' => 'target', 'users' => [entry] }
    assert_equal({ 'error' => 'invalid_request' }, TripKata::Contract.execute(request))
  end

  private

  def entry
    { 'id' => 'target', 'friends' => ['alice'], 'trips' => ['trip-1'] }
  end
end
