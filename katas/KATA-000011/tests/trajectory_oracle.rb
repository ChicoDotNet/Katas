# SPDX-License-Identifier: MIT
# Independent closed-form time-range counting, NOT a translation of Kotlin's daily branching.
require 'open3'

raise 'usage: ruby trajectory_oracle.rb path/to/trajectory.jar' unless ARGV.length == 1

NAMES = ['Apple', 'Conjured Cake', 'Aged Brie', 'Backstage passes', 'Sulfuras'].freeze
rng = Random.new(20261028)
cases = []
NAMES.each do |name|
  [-35, -31, -30, -1, 0, 1, 5, 6, 10, 11, 12, 30, 60].each do |sell_in|
    [0, 1, 2, 3, 25, 48, 49, 50].each do |quality|
      [0, 1, 5, 30, 31, 90, 365].each do |days|
        cases << [name, sell_in, name == 'Sulfuras' ? 80 : quality, days]
      end
    end
  end
end
3_000.times do
  name = NAMES.sample(random: rng)
  cases << [name, rng.rand(-40..70), name == 'Sulfuras' ? 80 : rng.rand(0..50), rng.rand(30..365)]
end
cases.uniq!

def closed_form(name, sell_in, quality, elapsed)
  return [name, sell_in, quality] if name == 'Sulfuras'
  active = [[sell_in, 0].max, elapsed].min
  expired = elapsed - active
  final_quality = case name
                  when 'Aged Brie'
                    [50, quality + active + 2 * expired].min
                  when 'Backstage passes'
                    if expired > 0
                      0
                    else
                      above_ten = [[sell_in - 10, 0].max, elapsed].min
                      above_five = [[sell_in - 5, 0].max, elapsed].min
                      gain = above_ten + 2 * (above_five - above_ten) + 3 * (active - above_five)
                      [50, quality + gain].min
                    end
                  else
                    rate = name.start_with?('Conjured ') ? 2 : 1
                    [0, quality - rate * (active + 2 * expired)].max
                  end
  [name, sell_in - elapsed, final_quality]
end

inputs = cases.map { |c| c.join('|') }.join("\n") + "\n"
stdout, stderr, status = Open3.capture3('java', '-jar', ARGV.fetch(0), stdin_data: inputs)
abort("Kotlin trajectory process failed: #{stderr}") unless status.success?
actual = stdout.lines.map(&:strip)
abort("wrong output count: #{actual.length} vs #{cases.length}") unless actual.length == cases.length
cases.each_with_index do |c, i|
  expected = closed_form(*c).join('|')
  abort("DIFFERENTIAL FAIL index=#{i} input=#{c.inspect} expected=#{expected} actual=#{actual[i]}") unless actual[i] == expected
end

# Independent algebraic semigroup check on the closed-form model itself.
# This guards the reference against accidental boundary-counting errors.
1_000.times do
  name = NAMES.sample(random: rng)
  sell_in = rng.rand(-40..70)
  quality = name == 'Sulfuras' ? 80 : rng.rand(0..50)
  first = rng.rand(0..180)
  second = rng.rand(0..185)
  left = closed_form(*closed_form(name, sell_in, quality, first), second)
  right = closed_form(name, sell_in, quality, first + second)
  abort("oracle semigroup failure #{[name, sell_in, quality, first, second].inspect}") unless left == right
end
puts "PASS: #{cases.length} Kotlin/Ruby closed-form multi-day comparisons; 1000 reference semigroup checks"
