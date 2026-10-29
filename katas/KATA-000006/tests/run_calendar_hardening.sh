#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ruby -c src/spending.rb
ruby -c tests/calendar_fault_hardening.rb
ruby tests/calendar_fault_hardening.rb
ruby -rtempfile -ropen3 -e '
source = File.read("src/spending.rb")
mutations = {
  "wrong-month-direction" => ["Date.new(month.year, month.month, 1) << 1", "Date.new(month.year, month.month, 1) >> 1"],
  "threshold-off-by-one" => ["amount * 2 >= last_month * 3", "amount * 2 > last_month * 3"],
  "missing-delivery" => ["@sender.deliver(user_id, mail) if mail", "nil if mail"]
}
mutations.each do |name, (before, after)|
  abort "FAIL: nonunique mutation anchor #{name}" unless source.scan(Regexp.new(Regexp.escape(before))).length == 1
  Tempfile.create(["ninja-spending-", ".rb"]) do |file|
    file.write(source.sub(before, after)); file.flush
    syntax, status = Open3.capture2("ruby", "-c", file.path)
    abort "FAIL: mutant #{name} does not compile: #{syntax}" unless status.success?
    output, err, result = Open3.capture3({"SPENDING_IMPL" => file.path}, "ruby", "tests/calendar_fault_hardening.rb")
    abort "FAIL: mutant #{name} survived" if result.success?
    abort "FAIL: mutant #{name} failed without Minitest behavior failure: #{output} #{err}" unless output.include?("Failure:")
    puts "PASS: compiled behavioral mutant #{name} detected"
  end
end
'
