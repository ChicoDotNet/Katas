# frozen_string_literal: true
require 'tmpdir'
require 'fileutils'

source = File.read(File.expand_path('../src/trip_service.rb', __dir__))
cli = File.read(File.expand_path('../src/cli.rb', __dir__))
oracle = File.expand_path('oracle.go', __dir__)
mutants = {
  'bypass-authentication' => ["viewer_id.nil?", 'false'],
  'friendship-hardcoded' => ['target.friend_ids.include?(viewer_id)', 'target.friend_ids.include?("alice")'],
  'discard-duplicate-trips' => ['target.trip_ids.dup', 'target.trip_ids.uniq']
}
mutants.each do |name, (old, replacement)|
  raise "mutation anchor missing #{name}" unless source.include?(old)
  Dir.mktmpdir('ninja-trip-mutant-') do |dir|
    File.write(File.join(dir, 'trip_service.rb'), source.sub(old, replacement))
    File.write(File.join(dir, 'cli.rb'), cli)
    raise "mutation #{name} not syntax-valid" unless system('ruby', '-c', File.join(dir, 'trip_service.rb'), out: File::NULL)
    output = IO.popen(['go', 'run', oracle, File.join(dir, 'cli.rb')], err: [:child, :out], &:read)
    # Go exits nonzero on a genuine oracle mismatch. Do not count toolchain crashes.
    status = $?.exitstatus
    raise "mutation #{name} escaped oracle" if status.zero?
    raise "mutation #{name} failed for non-behavioral reason: #{output}" unless output.include?(' mismatch: ')
    puts "MUTANT #{name}: syntax-valid and behaviorally rejected"
  end
end
puts "#{mutants.size}/#{mutants.size} Ruby mutants killed"
