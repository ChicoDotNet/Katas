# frozen_string_literal: true
# SPDX-License-Identifier: MIT
# Original MIT trace-contract monitor; does not import upstream GPL trivia code.
# Independent *verification technique* from Python's forward transcript generator:
# parse the emitted event protocol and check local state transitions, plus
# metamorphic relations across separate executions. This is not a formal proof.
require 'open3'

class TraceContract
  TOPICS = %w[LOGIC NATURE HISTORY ARTS].freeze
  def initialize(classes, modes)
    @classes = classes
    @modes = modes
    @checks = 0
  end
  attr_reader :checks

  def check(value, message)
    raise "TRACE CONTRACT FAILURE: #{message}" unless value
    @checks += 1
  end

  def run(mode, names, moves)
    input = "PLAYERS #{names.join(',')}\n" + moves.map { |roll, correct| "#{roll} #{correct ? 'C' : 'W'}\n" }.join
    output, errors, status = Open3.capture3('java', '-cp', @classes, 'TriviaCli', mode, stdin_data: input)
    check(status.success?, "CLI #{mode} exit #{status.exitstatus}: #{errors}")
    output
  end

  def verify_trace(names, moves, transcript)
    check(transcript.end_with?("\n"), 'missing final newline')
    events = transcript.lines.map(&:chomp)
    names.each { |name| check(events.shift == "WELCOME #{name}", 'WELCOME order') }
    station = Hash[names.map { |n| [n, 0] }]
    score = Hash[names.map { |n| [n, 0] }]
    paused = Hash[names.map { |n| [n, false] }]
    topics = Hash[TOPICS.map { |t| [t, 0] }]
    winner = false
    moves.each_with_index do |(roll, correct), i|
      break if winner
      who = names[i % names.size]
      check(events.shift == "TURN #{who} roll=#{roll}", "round-robin turn #{i}")
      if paused.fetch(who) && roll.odd?
        check(events.shift == "SKIP #{who}", "paused odd turn #{i}")
        next
      end
      if paused.fetch(who)
        check(events.shift == "RETURN #{who}", "paused even turn #{i}")
      end
      paused[who] = false
      station[who] = (station.fetch(who) + roll) % 12
      check(events.shift == "MOVE #{who} #{station.fetch(who)}", "station at #{i}")
      topic = TOPICS.fetch(station.fetch(who) % 4)
      topics[topic] += 1
      check(events.shift == "ASK #{topic}##{topics.fetch(topic)}", "topic counter #{i}")
      if correct
        score[who] += 1
        check(events.shift == "RIGHT #{who} score=#{score.fetch(who)}", "score #{i}")
        if score.fetch(who) == 5
          check(events.shift == "WIN #{who}", "win #{i}")
          winner = true
        end
      else
        paused[who] = true
        check(events.shift == "WRONG #{who}", "wrong #{i}")
      end
    end
    check(events.shift == 'NO_WINNER', 'missing NO_WINNER') unless winner
    check(events.empty?, "unexpected trailing events #{events.inspect}")
  end

  def verify_case(names, moves)
    @modes.each do |mode|
      original = run(mode, names, moves)
      verify_trace(names, moves, original)
      renamed = names.each_index.map { |i| "Q#{i}" }
      transformed = run(mode, renamed, moves)
      expected = original.gsub(/\bP(\d+)\b/) { "Q#{Regexp.last_match(1)}" }
      check(transformed == expected, "alpha-renaming equivariance #{mode}")
      prefix = moves.first(moves.size / 2)
      early = run(mode, names, prefix)
      if early.include?("\nWIN ")
        check(original == early, "terminal extension invariance #{mode}")
      else
        check(original.start_with?(early.delete_suffix("NO_WINNER\n")), "prefix monotonicity #{mode}")
      end
    end
  end
end

classes = ARGV.fetch(0)
modes = (ENV['TRIVIA_MODES'] || 'legacy,refactored').split(',')
cases_count = Integer(ENV.fetch('TRIVIA_CASES', '12'))
monitor = TraceContract.new(classes, modes)
rng = Random.new(20261029)
cases = [
  [%w[P0 P1], []],
  [%w[P0 P1], Array.new(20) { [2, true] }],
  [%w[P0 P1], Array.new(20) { [1, false] }],
  [%w[P0 P1 P2], Array.new(35) { |i| [i % 6 + 1, i % 3 != 0] }],
  [%w[P0 P1 P2 P3 P4 P5], Array.new(40) { |i| [i % 6 + 1, i % 4 != 0] }]
]
cases_count.times do
  names = Array.new(rng.rand(2..6)) { |i| "P#{i}" }
  moves = Array.new(rng.rand(0..110)) { [rng.rand(1..6), rng.rand(2) == 0] }
  cases << [names, moves]
end
cases.each { |names, moves| monitor.verify_case(names, moves) }
puts "PASS: #{cases.size} trace cases x #{modes.size} modes; #{monitor.checks} event/metamorphic assertions"
