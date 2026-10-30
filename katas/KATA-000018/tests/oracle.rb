# frozen_string_literal: true
# SPDX-License-Identifier: MIT
# Independent transcript-AST reference for the real Perl streaming CLI.
require 'open3'
require 'securerandom'

module OhceReference
  module_function
  def greeting(name, hour)
    salutation = if (0...6).cover?(hour) || (20...24).cover?(hour)
                   'Buenas noches'
                 elsif (6...12).cover?(hour)
                   'Buenos días'
                 else
                   'Buenas tardes'
                 end
    "¡#{salutation} #{name}!"
  end
  def output(name, hour, messages)
    events = [greeting(name, hour)]
    messages.each do |message|
      if message == 'Stop!'
        events << "Adios #{name}"
        break
      end
      # Reverse a list of extended grapheme clusters, not a codepoint string.
      clusters = message.grapheme_clusters
      reversed = clusters.reverse.join
      events << reversed
      events << '¡Bonita palabra!' if !clusters.empty? && clusters == clusters.reverse
    end
    events
  end
end

root = File.expand_path('..', __dir__)
source = ENV.fetch('OHCE_SOURCE', 'Ohce')
raise 'invalid oracle module' unless %w[Ohce OhceMutant].include?(source)

# Compare the actual process output to an independent event transcript model.
def actual(root, name, hour, messages, source)
  input = messages.empty? ? "" : messages.join("\n") + "\n"
  out, err, status = Open3.capture3({ 'OHCE_SOURCE' => source }, 'perl', '-I', 'src', 'src/ohce.pl', '--name', name, '--hour', hour.to_s,
                                    stdin_data: input, chdir: root)
  raise "Perl failed: #{err}" unless status.success?
  out.force_encoding(Encoding::UTF_8)
  raise "invalid UTF-8 output" unless out.valid_encoding?
  out.split("\n", -1)[0...-1]
end

cases = []
# Exhaustive transcript ASTs over three distinct event kinds, length <=4.
(0..4).each do |n|
  (0...(3**n)).each do |mask|
    code = mask
    sequence = Array.new(n) do
      item = %w[hola oto Stop!][code % 3]
      code /= 3
      item
    end
    [5, 6, 12, 20].each { |hour| cases << ['Ana', hour, sequence] }
  end
end
rng = Random.new(18018)
lexicon = ['hola', 'oto', 'Stop!', 'stop', '', 'abba', 'áb', 'mañana', '¡Hola!', 'A', 'ab']
120.times do
  hour = rng.rand(24)
  name = ['Ana', 'Pedro', 'Niña'][rng.rand(3)]
  messages = Array.new(rng.rand(1..12)) { lexicon[rng.rand(lexicon.length)] }
  cases << [name, hour, messages]
end
# Metamorphic involution: reverse(reverse(message)) == message, observed via two real Perl processes.
metamorphic = 0
60.times do
  original = ['hola', 'mañana', 'áb', 'abcde'][rng.rand(4)]
  first = actual(root, 'Ana', 12, [original], source)
  raise 'missing reversal' unless first.length >= 2
  reversed = first[1]
  second = actual(root, 'Ana', 12, [reversed], source)
  raise "double reversal failed: #{original.inspect}" unless second[1] == original
  metamorphic += 1
end
# Negative CLI contracts are distinct from the scoring/session model.
invalid_args = [[], ['--hour', '12'], ['--name', 'Ana', '--hour', '24'],
                ['--name', 'Ana', '--hour', '-1'], ['--name', 'Ana', '--hour', '06'],
                ['--name', 'Ana', '--bogus', '1'],
                ['--name', 'Ana', '--name', 'Bob'],
                ['--name', 'Ana', '--hour', '12', '--hour', '20']]
invalid_args.each do |args|
  _out, _err, status = Open3.capture3('perl', '-I', 'src', 'src/ohce.pl', *args, stdin_data: '', chdir: root)
  raise "invalid CLI accepted #{args.inspect}" if status.success?
end
# A Unicode CLI must reject malformed input bytes rather than emit a replacement or mojibake.
_out, _err, invalid_stdin_status = Open3.capture3('perl', '-I', 'src', 'src/ohce.pl', '--name', 'Ana', '--hour', '12',
                                                  stdin_data: "\xFF\n".b, chdir: root)
raise 'malformed UTF-8 input accepted' if invalid_stdin_status.success?
cases.each_with_index do |(name, hour, messages), index|
  expected = OhceReference.output(name, hour, messages)
  observed = actual(root, name, hour, messages, source)
  raise "oracle mismatch ##{index}: #{[name, hour, messages].inspect}: #{observed.inspect} != #{expected.inspect}" unless observed == expected
end
puts "RUBY AST-first transcript oracle PASS: #{cases.length} Perl sessions, #{metamorphic} observed double-reversal metamorphic pairs, #{invalid_args.length} malformed CLI invocations rejected; invalid UTF-8 input rejected"
