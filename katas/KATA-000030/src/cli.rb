# frozen_string_literal: true
require 'json'
require_relative 'trip_service'

STDIN.each_line do |line|
  begin
    request = JSON.parse(line)
    result = TripKata::Contract.execute(request)
  rescue JSON::ParserError, Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
    result = { 'error' => 'invalid_request' }
  end
  STDOUT.puts(JSON.generate(result))
end
