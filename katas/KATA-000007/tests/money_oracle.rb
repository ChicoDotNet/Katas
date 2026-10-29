# SPDX-License-Identifier: MIT
# Independent unbounded-integer accounting model and metamorphic tests.
# Unlike C++'s bounded per-line arithmetic, Ruby computes exact totals first,
# then checks representability of the final tax-inclusive amount.
require 'open3'
require 'timeout'

MAX_CENTS = (1 << 63) - 1
RNG = Random.new(20261029)
RATES = [0, 1, 125, 999, 1600, 2000].freeze

def model(rate, operations)
  state = 0
  subtotal = 0
  line_count = 0
  accepted = 0
  refused = 0
  operations.each do |op, quantity, cents|
    ok = false
    case op
    when 'A'
      if state == 0 && quantity > 0 && cents >= 0
        candidate = subtotal + quantity * cents
        tax = (candidate * rate + 5000) / 10_000
        if candidate + tax <= MAX_CENTS
          subtotal = candidate
          line_count += 1
          ok = true
        end
      end
    when 'P'
      if state == 0 && line_count.positive?
        state = 1
        ok = true
      end
    when 'R'
      if state == 0 || state == 1
        state = 2
        ok = true
      end
    when 'S'
      if state == 1
        state = 3
        ok = true
      end
    end
    ok ? accepted += 1 : refused += 1
  end
  tax = (subtotal * rate + 5000) / 10_000
  [state, subtotal, tax, subtotal + tax, accepted, refused]
end

def serialize(rate, operations)
  ([rate.to_s] + operations.map { |op, q, c| op == 'A' ? "A,#{q},#{c}" : op }).join('|')
end

def execute(cli, cases)
  stdin = cases.map { |rate, operations| serialize(rate, operations) }.join("\n") + "\n"
  out, err, status = Timeout.timeout(30) { Open3.capture3(cli, stdin_data: stdin) }
  abort "FAIL: C++ CLI exit #{status.exitstatus}: #{err}" unless status.success?
  lines = out.lines.map(&:strip)
  abort "FAIL: CLI produced #{lines.size} rows, expected #{cases.size}" unless lines.size == cases.size
  lines.each_with_index.map do |line, i|
    abort "FAIL: CLI ERROR at case #{i}: #{serialize(*cases[i])}" if line == 'ERROR'
    line.split(';').map { |n| Integer(n, 10) }
  end
end

abort 'usage: ruby money_oracle.rb /path/to/cli' unless ARGV.length == 1
cli = ARGV.fetch(0)
cases = []
# Explicit boundary witnesses, including exact maximum totals and one-cent overflow.
RATES.each do |rate|
  low, high = 0, MAX_CENTS
  while low < high
    mid = (low + high + 1) / 2
    mid + (mid * rate + 5000) / 10_000 <= MAX_CENTS ? low = mid : high = mid - 1
  end
  cases << [rate, [['A', 1, low], ['A', 1, 1], ['P', 0, 0], ['S', 0, 0]]]
  cases << [rate, [['A', rate.zero? ? 2 : 1, rate.zero? ? MAX_CENTS : low + 1], ['A', 1, 0], ['P', 0, 0]]]
end
# Mixed boundary, invalid-input and lifecycle cases.
values = [0, 1, 2, 10, 9_999, 1_000_000, MAX_CENTS / 2,
          MAX_CENTS - 1, MAX_CENTS]
1_200.times do
  rate = RATES.sample(random: RNG)
  ops = Array.new(RNG.rand(1..22)) do
    op = %w[A A A A P R S X].sample(random: RNG)
    q = (values + [-1, -2, 3, 7]).sample(random: RNG)
    c = (values + [-1, 3, 17, 1_000_000_000]).sample(random: RNG)
    [op, q, c]
  end
  cases << [rate, ops]
end
expected = cases.map { |rate, ops| model(rate, ops) }
actual = execute(cli, cases)
actual.zip(expected).each_with_index do |(got, want), index|
  abort "FAIL: exact BigInteger case #{index}: expected #{want.inspect}, got #{got.inspect}, input #{serialize(*cases[index])}" unless got == want
end
puts "PASS: #{cases.length} exact Ruby BigInteger accounting scenarios"

# Metamorphic tests use safe, nonnegative, finite line sets: all permutations
# must have the same monetary result, and splitting a quantity must preserve it.
metamorphic = []
300.times do
  rate = RATES.sample(random: RNG)
  lines = Array.new(RNG.rand(2..12)) { ['A', RNG.rand(1..100), RNG.rand(0..1_000_000)] }
  metamorphic << [rate, lines + [['P', 0, 0], ['S', 0, 0]]]
  metamorphic << [rate, lines.shuffle(random: RNG) + [['P', 0, 0], ['S', 0, 0]]]
  first = lines.first
  split = [['A', 1, first[2]], ['A', first[1] - 1, first[2]]] + lines.drop(1)
  # If first quantity is one, a zero-quantity split would be rejected, so
  # retain the original first line rather than creating an invalid event.
  split = lines if first[1] == 1
  metamorphic << [rate, split + [['P', 0, 0], ['S', 0, 0]]]
end
results = execute(cli, metamorphic)
300.times do |i|
  base, shuffled, split = results.slice(i * 3, 3)
  abort "FAIL: permutation #{i}" unless base[0, 4] == shuffled[0, 4]
  abort "FAIL: quantity splitting #{i}" unless base[0, 4] == split[0, 4]
end
puts 'PASS: 600 metamorphic permutation/splitting invariants (900 executed histories)'
