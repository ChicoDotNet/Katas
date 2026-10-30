# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'tmpdir'
require 'fileutils'
source = File.read('src/tennis.rb')
mutations = {
  'deuce-too-early' => ['return self.class.new(:deuce) if a == 3 && b == 3', 'return self.class.new(:deuce) if a == 2 && b == 2'],
  'winner-not-terminal' => ['return self.class.new(:won_a) if a == 4', 'return self.class.new(:adv_a) if a == 4'],
  'advantage-does-not-reset' => ["self.class.new(player == 'A' ? :won_a : :deuce)", "self.class.new(player == 'A' ? :won_a : :adv_a)"]
}
Dir.mktmpdir('tennis-mutants-') do |dir|
  mutations.each do |name,(old,new_code)|
    raise "mutation anchor not unique: #{name}" unless source.scan(old).length == 1
    mutated = source.sub(old,new_code)
    file=File.join(dir,"#{name}.rb")
    File.write(file,mutated)
    raise "mutant syntax failure #{name}" unless system('ruby','-c',file,out:File::NULL)
    env={'TENNIS_SOURCE'=>file}
    # Running independent oracle against the actual compiled/parsed mutant.
    ok=system(env,'go','run','tests/oracle.go','src/cli.rb',out:File::NULL,err:File::NULL)
    raise "MUTANT SURVIVED #{name}" if ok
    puts "COMPILED/PARSED MUTANT KILLED: #{name}"
  end
end
puts '3/3 mutant variants detected'
