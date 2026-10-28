# SPDX-License-Identifier: MIT
# Independent Ruby model: BigDecimal arithmetic and key-based sorting.
require 'bigdecimal'
require 'date'
require 'open3'
require 'securerandom'

def ruby_money(cents, locale, currency)
  amount = BigDecimal(cents.to_s) / BigDecimal('100')
  unsigned = amount.abs.to_s('F')
  whole, fraction = unsigned.split('.', 2)
  fraction = (fraction || '').ljust(2, '0')[0, 2]
  grouping = locale == 'en_US' ? ',' : '.'
  grouped = whole.reverse.scan(/.{1,3}/).join(grouping).reverse
  mark = currency == 'USD' ? '$' : '€'
  rendered = if locale == 'en_US'
    cents < 0 ? "(#{mark}#{grouped}.#{fraction})" : "#{mark}#{grouped}.#{fraction} "
  else
    "#{mark} #{cents < 0 ? '-' : ''}#{grouped},#{fraction} "
  end
  raise 'oracle amount too wide' if rendered.length > 13
  rendered.rjust(13)
end

def ruby_ledger(entries, locale, currency)
  header = locale == 'en_US' ? 'Date       | Description               | Change       ' : 'Datum      | Omschrijving              | Verandering  '
  rows = entries.sort_by { |date, desc, cents| [Date.iso8601(date), desc, cents] }.map do |date, desc, cents|
    d = Date.iso8601(date)
    display_date = locale == 'en_US' ? d.strftime('%m/%d/%Y') : d.strftime('%d-%m-%Y')
    label = desc.length > 25 ? desc[0,22] + '...' : desc
    "#{display_date} | #{label.ljust(25)} | #{ruby_money(cents, locale, currency)}"
  end
  ([header] + rows).join("\n") + "\n"
end

def execute(exe, entries, locale, currency)
  input = entries.map { |date, desc, cents| "#{date}\t#{desc}\t#{cents}\n" }.join
  stdout, stderr, status = Open3.capture3(exe, locale, currency, stdin_data: input)
  raise "C++ rejected valid ledger: #{stderr}" unless status.success?
  stdout.force_encoding(Encoding::UTF_8)
end

exe = ARGV.fetch(0)
rng = Random.new(20261028)
dates = %w[2000-02-29 2015-01-01 2015-01-02 2016-02-29 2024-12-31 2026-10-28]
descs = ['A', 'B', 'Same', 'Alpha', 'Long name with more than twenty five characters', 'Very Long But Not Too Long', '']
comparisons = 0
metamorphic = 0
240.times do |i|
  count = rng.rand(0..15)
  entries = Array.new(count) { [dates.sample(random: rng), descs.sample(random: rng), rng.rand(-8_000_000..8_000_000)] }
  %w[en_US nl_NL].product(%w[USD EUR]).each do |locale, currency|
    want = ruby_ledger(entries, locale, currency)
    got = execute(exe, entries, locale, currency)
    raise "differential mismatch case #{i} #{locale} #{currency}\nwant=#{want.inspect}\ngot=#{got.inspect}" unless got == want
    comparisons += 1
    if i % 3 == 0
      reordered = entries.shuffle(random: rng)
      raise "permutation metamorphism failed case #{i}" unless execute(exe, reordered, locale, currency) == got
      metamorphic += 1
    end
  end
end
# Strict invalid input and locale contracts.
invalid = [
  ['en_GB','USD',"2015-01-01\tA\t100\n"],
  ['en_US','GBP',"2015-01-01\tA\t100\n"],
  ['en_US','USD',"2015-02-29\tA\t100\n"],
  ['en_US','USD',"2015-01-01\tA\t100x\n"],
  ['en_US','USD',"2015-01-01\tA\t9223372036854775808\n"],
  ['en_US','USD',"2015-01-01\tA\n"],
  ['en_US','USD',"2015-01-01\tA\t100\textra\n"],
]
invalid.each do |locale,currency,data|
  _out,_err,status=Open3.capture3(exe,locale,currency,stdin_data:data)
  raise 'invalid input accepted' if status.success?
end
puts "PASS Ruby BigDecimal/key-sort differential: #{comparisons} cases; #{metamorphic} permutations; #{invalid.size} invalid rejections"
