# frozen_string_literal: true
# Original implementation. The public Kata-Log idea is referenced, not its starters.
module TripKata
  class RequestError < StandardError
    attr_reader :code
    def initialize(code)
      @code = code
      super(code)
    end
  end

  User = Struct.new(:id, :friend_ids, :trip_ids, keyword_init: true)

  class UserDirectory
    def initialize(users)
      @by_id = users.to_h { |user| [user.id, user] }
    end

    def fetch(id)
      @by_id[id]
    end
  end

  # Session boundary is deliberately injectable; no hidden global authentication state.
  class Session
    attr_reader :viewer_id
    def initialize(viewer_id)
      @viewer_id = viewer_id
    end
  end

  class TripService
    def initialize(directory:, session:)
      @directory = directory
      @session = session
    end

    def trips_for(target_id)
      viewer_id = @session.viewer_id
      raise RequestError, 'not_logged_in' if viewer_id.nil?

      target = @directory.fetch(target_id)
      raise RequestError, 'user_not_found' if target.nil?

      return [] unless viewer_id == target.id || target.friend_ids.include?(viewer_id)

      target.trip_ids.dup
    end
  end

  module Contract
    module_function

    def parse(request)
      raise RequestError, 'invalid_request' unless request.is_a?(Hash)
      raise RequestError, 'invalid_request' unless request.keys.sort == %w[target users viewer]
      viewer, target, users = request.values_at('viewer', 'target', 'users')
      raise RequestError, 'invalid_request' unless viewer.nil? || identifier?(viewer)
      raise RequestError, 'invalid_request' unless identifier?(target)
      raise RequestError, 'invalid_request' unless users.is_a?(Array)

      seen = {}
      normalized = users.map do |entry|
        raise RequestError, 'invalid_request' unless entry.is_a?(Hash) && entry.keys.sort == %w[friends id trips]
        id, friends, trips = entry.values_at('id', 'friends', 'trips')
        raise RequestError, 'invalid_request' unless identifier?(id) && !seen[id]
        raise RequestError, 'invalid_request' unless friends.is_a?(Array) && friends.all? { |f| identifier?(f) }
        raise RequestError, 'invalid_request' unless trips.is_a?(Array) && trips.all? { |t| identifier?(t) }
        seen[id] = true
        User.new(id: id, friend_ids: friends.freeze, trip_ids: trips.freeze).freeze
      end
      [viewer, target, normalized]
    end

    def identifier?(value)
      value.is_a?(String) && !value.empty? && value.valid_encoding?
    end

    def execute(request)
      viewer, target, users = parse(request)
      service = TripService.new(directory: UserDirectory.new(users), session: Session.new(viewer))
      { 'trips' => service.trips_for(target) }
    rescue RequestError => e
      { 'error' => e.code }
    end
  end
end
