#!/usr/bin/env ruby
# Independent Ruby Array/event-log oracle for original C++ pointer-owned doubly linked list.
require 'open3'
DRIVER = ENV.fetch('LIST_DRIVER')
RNG = Random.new(0x41A17)
TOTAL = 0

def verify(commands, expected, label)
  stdout, stderr, status = Open3.capture3(DRIVER, stdin_data: commands.join("\n") + "\n")
  raise "#{label}: driver exited #{status.exitstatus}: #{stderr}" unless status.success?
  actual = stdout.lines.map(&:chomp)
  unless actual == expected
    mismatch = actual.zip(expected).each_with_index.find { |(a, b), _i| a != b }
    raise "#{label}: mismatch #{mismatch.inspect} actual length #{actual.length} expected #{expected.length}"
  end
  $requests += commands.length
end

def history(scenario)
  model = []
  commands = []
  expected = []
  operations = [:push_front, :push_back, :pop_front, :pop_back, :erase]
  140.times do |step|
    op = operations[RNG.rand(operations.length)]
    v = if step % 37 == 0
      [-9_223_372_036_854_775_808, 9_223_372_036_854_775_807][RNG.rand(2)]
    else
      RNG.rand(-15..15)
    end
    case op
    when :push_front
      commands << "PUSH_FRONT #{v}"; expected << 'OK'; model.unshift(v)
    when :push_back
      commands << "PUSH_BACK #{v}"; expected << 'OK'; model.push(v)
    when :pop_front
      commands << 'POP_FRONT'; expected << (model.empty? ? 'MISS' : "VALUE #{model.shift}")
    when :pop_back
      commands << 'POP_BACK'; expected << (model.empty? ? 'MISS' : "VALUE #{model.pop}")
    when :erase
      commands << "ERASE #{v}"; i = model.index(v)
      expected << (i ? 'FOUND' : 'MISS'); model.delete_at(i) if i
    end
    if step % 7 == 0
      commands << 'SNAP'; expected << "LIST #{model.size}#{model.empty? ? '' : ' ' + model.join(' ')}"
      commands << 'REV'; expected << "LIST #{model.size}#{model.empty? ? '' : ' ' + model.reverse.join(' ')}"
      commands << 'CHECK'; expected << 'VALID'
      commands << 'SIZE'; expected << "SIZE #{model.size}"
    end
    # Metamorphic inverse: a push then corresponding pop leaves the entire route unchanged.
    if step % 29 == 0
      commands << "PUSH_FRONT #{v}"; expected << 'OK'
      commands << 'POP_FRONT'; expected << "VALUE #{v}"
      commands << 'SNAP'; expected << "LIST #{model.size}#{model.empty? ? '' : ' ' + model.join(' ')}"
    end
  end
  verify(commands, expected, "history #{scenario}")
end
$requests = 0
90.times { |i| history(i) }
# Invalid commands must not be silently interpreted as valid state transitions.
['PUSH_FRONT', 'PUSH_BACK abc', 'ERASE 9223372036854775808', 'SNAP extra', 'WHAT', 'PUSH_BACK 1.5'].each do |bad|
  _stdout, _stderr, status = Open3.capture3(DRIVER, stdin_data: "#{bad}\n")
  raise "accepted invalid command #{bad}" if status.success?
end
puts "ORACLE PASS 90 independent Ruby array histories, #{$requests} C++ commands, inverse push/pop metamorphism, 6 invalid requests"
