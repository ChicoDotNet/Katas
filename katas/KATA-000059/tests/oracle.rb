# frozen_string_literal: true
# Ruby's Set-based state model and an independently enumerated finite name
# universe check a Swift actor; neither implements its RNG/reservoir algorithm.
require 'json'
require 'open3'
require 'set'

CLI = ARGV.fetch(0)
RNG = Random.new(59_2026)

def check(condition, message)
  raise "ORACLE FAIL: #{message}" unless condition
end

def invoke(cases)
  input = cases.map { |x| JSON.generate(x) }.join("\n") + "\n"
  output, error, status = Open3.capture3(CLI, stdin_data: input)
  check(status.success?, "Swift CLI exit #{status.exitstatus}: #{error}")
  lines = output.lines
  check(lines.size == cases.size, "expected #{cases.size} JSON results, got #{lines.size}")
  lines.map { |line| JSON.parse(line) }
end

def universe(letters, digits)
  (0...letters).flat_map do |a|
    (0...letters).flat_map do |b|
      (0...digits).map { |d| format('%c%c%03d', 65 + a, 65 + b, d) }
    end
  end.to_set
end

def verify_history(test, result)
  letters = test.fetch('letters')
  digits = test.fetch('digits')
  all_names = universe(letters, digits) # Cartesian enumeration, no Swift index arithmetic.
  state = {}
  previous = {}
  used = Set.new
  responses = result.fetch('results')
  check(responses.length == test.fetch('ops').length, 'result length')
  test.fetch('ops').zip(responses).each_with_index do |(op, response), i|
    id = op.fetch('id')
    action = op.fetch('op')
    if action == 'new'
      if state.key?(id)
        check(response == {'error' => 'duplicate_id'}, "duplicate ID at #{i}")
      else
        check(response == {'ok' => true}, "new at #{i}")
        state[id] = nil
        previous.delete(id)
      end
    elsif !state.key?(id)
      check(response == {'error' => 'unknown_robot'}, "unknown ID at #{i}")
    elsif action == 'name'
      current = state[id]
      if current
        check(response == {'name' => current}, "idempotence at #{i}")
      else
        allowed = all_names - used
        allowed.delete(previous[id]) if previous[id]
        if allowed.empty?
          check(response == {'error' => 'exhausted'}, "exhaustion at #{i}")
        else
          name = response['name']
          check(name.is_a?(String) && name.match?(/\A[A-Z]{2}\d{3}\z/), "format at #{i}")
          check(allowed.include?(name), "collision/repeated reset/invalid name at #{i}: #{name}")
          used.add(name)
          state[id] = name
          previous.delete(id)
        end
      end
    elsif action == 'reset'
      check(response == {'ok' => true}, "reset at #{i}")
      old = state[id]
      used.delete(old) if old
      previous[id] = old if old
      state[id] = nil
    elsif action == 'retire'
      check(response == {'ok' => true}, "retire at #{i}")
      used.delete(state[id]) if state[id]
      state.delete(id)
      previous.delete(id)
    else
      check(response == {'error' => 'invalid_operation'}, "invalid operation at #{i}")
    end
  end
  check(used.size == state.values.compact.size, 'active name uniqueness')
  responses.length
end

cases = []
90.times do |n|
  letters = 2 + RNG.rand(2)
  digits = 2 + RNG.rand(3)
  ops = []
  (90 + RNG.rand(70)).times do
    id = "r#{RNG.rand(26)}"
    action = %w[new name name name reset retire bogus][RNG.rand(7)]
    ops << {'op' => action, 'id' => id}
  end
  cases << {'seed' => n * 13 + 3, 'letters' => letters, 'digits' => digits, 'ops' => ops}
end
# Exhaust every available name in a tiny universe. This checks the pigeonhole
# bound and the complete Cartesian product, independently of random order.
10.times do |seed|
  ops = (0..8).flat_map { |i| [{'op' => 'new', 'id' => "r#{i}"}, {'op' => 'name', 'id' => "r#{i}"}] }
  ops += [{'op' => 'retire', 'id' => 'r0'}, {'op' => 'name', 'id' => 'r8'}]
  cases << {'seed' => seed + 100, 'letters' => 2, 'digits' => 2, 'ops' => ops}
end
responses = invoke(cases)
checks = cases.zip(responses).sum { |test, response| verify_history(test, response) }

# Metamorphism: an additional name query must not consume randomness.
base_ops = (0...15).flat_map { |i| [{'op' => 'new', 'id' => "r#{i}"}, {'op' => 'name', 'id' => "r#{i}"}] }
base = {'seed' => 991, 'letters' => 3, 'digits' => 5, 'ops' => base_ops}
extra_ops = base_ops.dup.insert(2, {'op' => 'name', 'id' => 'r0'})
variant = base.merge('ops' => extra_ops)
a, b = invoke([base, variant]).map { |x| x.fetch('results') }
check(a == b.reject.with_index { |_, i| i == 2 }, 'idempotent query changed later RNG choices')
check(b[1] == b[2], 'extra query must repeat the same name')

# Replaying the deterministic test seed must reproduce the entire trace.
repeat = invoke([base, base])
check(repeat[0] == repeat[1], 'seeded test replay differs')

# The production RNG is not seeded. Seeded test-only runs should still exhibit
# diverse first names, rather than an obvious counter or a fixed constant.
seeds = (0...30).map do |i|
  {'seed' => i, 'letters' => 26, 'digits' => 1000,
   'ops' => [{'op' => 'new', 'id' => 'x'}, {'op' => 'name', 'id' => 'x'}]}
end
samples = invoke(seeds).map { |r| r.fetch('results').last.fetch('name') }
check(samples.uniq.size >= 20, 'seeded samples insufficiently diverse')

bad = invoke([{'letters' => 0, 'digits' => 1, 'ops' => []}]).first
check(bad == {'error' => 'invalid_configuration'}, 'invalid configuration')
puts "ORACLE Ruby PASS: #{cases.size} histories, #{checks} operations, 10 complete name universes, metamorphic/idempotence/replay, seeded diversity"
