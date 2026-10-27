# frozen_string_literal: true
require 'open3'

bin = ARGV.fetch(0)
seed = 61_202_610
rng = Random.new(seed)
# These are single Unicode scalar values, deliberately including code points
# that form a single grapheme cluster when adjacent (combining, ZWJ, flags).
tokens = [0x41, 0x7a, 0x00, 0x0a, 0x00e9, 0x0301, 0x200d, 0x65e5,
          0x1f61b, 0x1f469, 0x1f4bb, 0x1f1f2, 0x1f1fd, 0x10ffff,
          0x0800, 0x007f, 0x0080, 0x07ff, 0x10000]
inputs = []
expected = []
add = lambda do |bytes, answer|
  inputs << bytes.unpack1('H*')
  expected << answer
end
# Strategy A: token-first construction. Expected result comes from the
# *generator's scalar token sequence*, not a second UTF-8 decoder.
1_800.times do
  values = Array.new(rng.rand(0..35)) { tokens.fetch(rng.rand(tokens.size)) }
  raw = values.pack('U*')
  add.call(raw, values.first(5).pack('U*').unpack1('H*'))
end
# Strategy B: Ruby's own Unicode codepoint iterator on a distinct corpus.
700.times do
  values = Array.new(rng.rand(0..45)) { rng.rand(0..0x10ffff) }
  values.reject! { |v| v.between?(0xd800, 0xdfff) }
  raw = values.pack('U*')
  add.call(raw, raw.codepoints.first(5).pack('U*').unpack1('H*'))
end
# Full-input validation, including malformed suffix after five valid scalars.
malformed = ["\xC0\xAF", "\xE0\x80\x80", "\xED\xA0\x80",
             "\xF4\x90\x80\x80", "\xF0\x9F\x98", "\xFF",
             "\x80", "\xE2\x28\xA1", "\xF5\x80\x80\x80",
             "\xC2", "\xFE", "\xE0\x9F\xBF"]
malformed.each do |bad|
  ["", "abcde", "xyz"].each do |prefix|
    add.call((prefix.b + bad.b), 'ERR')
  end
end
# Invalid hex is a separate transport error, not a Unicode error.
['f', 'xz', '0x', 'aaa', 'GG'].each do |bad_hex|
  inputs << bad_hex
  expected << 'ERR'
end
# Idempotence and suffix invariance are checked on real binary responses.
stdin = inputs.join("\n") + "\n"
stdout, stderr, status = Open3.capture3(bin, stdin_data: stdin)
abort("binary failed #{status.exitstatus}: #{stderr}") unless status.success?
actual = stdout.split("\n", -1)
actual.pop if actual.last == ''
abort("line count #{actual.size} != #{expected.size}") unless actual.size == expected.size
actual.zip(expected).each_with_index do |(got, want), i|
  abort("case #{i} expected=#{want} got=#{got}") unless got == want
end
valid_hex = actual.reject { |x| x == 'ERR' }
more_input = valid_hex.join("\n") + "\n"
again, err2, status2 = Open3.capture3(bin, stdin_data: more_input)
abort("idempotence binary failed #{status2.exitstatus}: #{err2}") unless status2.success?
again_lines = again.split("\n", -1)
again_lines.pop if again_lines.last == ''
abort('idempotence mismatch') unless again_lines == valid_hex
# Once a post already contains five scalars, appending a valid scalar cannot
# change its prefix. This checks actual executions rather than Ruby-only math.
full = inputs.zip(expected).select do |hex, want|
  want != 'ERR' && [hex].pack('H*').force_encoding('UTF-8').codepoints.size >= 5
end
with_suffix = full.map { |hex, _| hex + '61' }.join("\n") + "\n"
suffix_out, suffix_err, suffix_status = Open3.capture3(bin, stdin_data: with_suffix)
abort("suffix binary failed #{suffix_status.exitstatus}: #{suffix_err}") unless suffix_status.success?
suffix_lines = suffix_out.split("\n", -1)
suffix_lines.pop if suffix_lines.last == ''
abort('suffix invariance mismatch') unless suffix_lines == full.map(&:last)
puts "ORACLE_PASS cases=#{expected.size} token_model=1800 ruby_codepoints=700 malformed=#{malformed.size * 3} idempotence=#{valid_hex.size} suffix=#{full.size}"
