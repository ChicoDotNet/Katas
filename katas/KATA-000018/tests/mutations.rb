# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'tmpdir'
require 'fileutils'
require 'open3'
source = File.read('src/Ohce.pm', encoding: 'UTF-8')
mutations = {
  'wrong-noon-boundary' => ['return "¡Buenos días $name!" if $hour < 12;', 'return "¡Buenos días $name!" if $hour < 13;'],
  'split-combining-mark' => ['my @clusters = $message =~ /\\X/g;', 'my @clusters = split //, $message;'],
  'reverse-is-identity' => ["return join '', reverse @clusters;", "return join '', @clusters;"]
}
Dir.mktmpdir('ohce-mutants-') do |dir|
  mutations.each do |name, (before, after)|
    raise "nonunique mutation anchor #{name}" unless source.scan(before).length == 1
    changed = source.sub(before, after).sub('package Ohce;', 'package OhceMutant;')
    file = File.join(dir, 'OhceMutant.pm')
    File.write(file, changed)
    _out, _err, syntax = Open3.capture3('perl', '-c', file)
    raise "mutant did not compile #{name}" unless syntax.success?
    _stdout, _stderr, status = Open3.capture3({'OHCE_SOURCE'=>'OhceMutant', 'PERL5LIB'=>dir}, 'ruby', 'tests/oracle.rb')
    raise "MUTANT SURVIVED #{name}" if status.success?
    raise "invalid mutant kill #{name}: #{_stderr}" unless _stderr.match?(/oracle mismatch|double reversal failed/)
    puts "COMPILED MUTANT KILLED: #{name}"
  end
end
puts '3/3 compiled Perl mutants detected'
