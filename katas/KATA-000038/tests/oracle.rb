#!/usr/bin/env ruby
# Independent event-replay reference: no incremental net-pair state.
require 'json'
require 'open3'
require 'bigdecimal'

abort 'usage: ruby tests/oracle.rb /path/to/driver' unless ARGV.size == 1
rng = Random.new(38_026)
checked = 0
histories = 0

class Replay
  attr_reader :names
  def initialize(names)
    @names = names.dup
    @events = [] # immutable ledger of (creditor, debtor, exact cents)
  end
  def snapshot(wanted = @names)
    wanted.uniq.sort.map do |name|
      owed_by = {}; owes = {}; balance = 0
      (@names - [name]).each do |other|
        # O(n² × transactions) intentionally different from incremental Go net-pair storage.
        net = @events.sum do |lender, borrower, cents|
          if lender == name && borrower == other then cents
          elsif lender == other && borrower == name then -cents
          else 0 end
        end
        if net.positive? then owed_by[other] = net
        elsif net.negative? then owes[other] = -net end
        balance += net
      end
      {'name' => name, 'owes' => owes, 'owed_by' => owed_by, 'balance' => balance}
    end
  end
  def add(name)
    return 409 if @names.include?(name)
    return 400 if name.empty? || name.strip != name || name.bytesize > 100
    @names << name
    200
  end
  def lend(lender, borrower, cents)
    return 400 if lender == borrower
    return 404 unless @names.include?(lender) && @names.include?(borrower)
    return 400 unless cents.is_a?(Integer) && cents > 0 && cents <= 100_000_000_000
    prior = @events.sum { |l,b,c| l == lender && b == borrower ? c : l == borrower && b == lender ? -c : 0 }
    return 400 if (prior + cents).abs > 100_000_000_000
    @events << [lender, borrower, cents]
    200
  end
end

def normalized_users(users)
  users.map do |u|
    {'name' => u.fetch('name'),
     'owes' => u.fetch('owes').transform_values { |v| (v * 100).round },
     'owed_by' => u.fetch('owed_by').transform_values { |v| (v * 100).round },
     'balance' => (u.fetch('balance') * 100).round}
  end
end

def verify!(actual, expected, status, context)
  raise "#{context}: status #{actual['status']} != #{status}" unless actual['status'] == status
  return if status != 200
  received = actual.fetch('body')
  if expected.is_a?(Array)
    received = received.fetch('users')
    received = normalized_users(received)
  else
    received = normalized_users([received]).first
  end
  raise "#{context}: received #{received.inspect} expected #{expected.inspect}" unless received == expected
end

Open3.popen3(ARGV[0]) do |stdin, stdout, stderr, wait|
  talk = lambda do |command|
    stdin.puts(JSON.generate(command));stdin.flush
    raw = stdout.gets
    raise "premature EOF: #{command.inspect}; stderr=#{stderr.read}" if raw.nil?
    JSON.parse(raw)
  end
  65.times do |h|
    names = %w[Ada Bob Cal Dee].take(2 + rng.rand(3))
    model = Replay.new(names)
    reset = talk.call({'reset' => names})
    raise "reset failed #{reset}" unless reset == {'status' => 200, 'body' => {'reset' => true}}
    histories += 1
    45.times do |step|
      mode = rng.rand(12)
      cmd = nil
      if mode < 7
        lender, borrower = names.sample(2, random: rng)
        cents = 1 + rng.rand(50_000)
        amount = cents / 100.0
        cmd = {'method'=>'POST', 'path'=>'/iou', 'body'=>{'lender'=>lender,'borrower'=>borrower,'amount'=>amount}}
        exact_cents = BigDecimal(amount.to_s) * 100
        raise 'Ruby BigDecimal detected fractional cents' unless exact_cents.frac.zero?
        code = model.lend(lender,borrower,exact_cents.to_i)
        expected = model.snapshot([lender,borrower])
      elsif mode == 7
        lender,borrower=names.sample(2,random:rng)
        cmd={'method'=>'POST','path'=>'/iou','body'=>{'lender'=>lender,'borrower'=>borrower,'amount'=>0}}
        code=400;expected=nil
      elsif mode == 8
        cmd={'method'=>'POST','path'=>'/unknown','body'=>{}}
        code=404;expected=nil
      elsif mode == 9
        cmd={'method'=>'GET','path'=>'/users'}
        code=200;expected=model.snapshot
      elsif mode == 10
        subset=names.shuffle(random:rng).take(1+rng.rand(names.length))
        cmd={'method'=>'GET','path'=>'/users','body'=>{'users'=>subset}}
        code=200;expected=model.snapshot(subset)
      else
        newname="New#{h}_#{step}"
        cmd={'method'=>'POST','path'=>'/add','body'=>{'user'=>newname}}
        code=model.add(newname);names << newname if code==200
        expected=model.snapshot([newname]).first
      end
      result=talk.call(cmd)
      verify!(result,expected,code,"history #{h} step #{step} #{cmd}")
      checked += 1
      # Independent postcondition: every successful or rejected command must preserve
      # the entire graph snapshot and global zero-sum balance.
      full=talk.call({'method'=>'GET','path'=>'/users'})
      expected_full=model.snapshot
      verify!(full,expected_full,200,"full state #{h}/#{step}")
      raise "nonzero conservation #{h}/#{step}" unless expected_full.sum { |u| u['balance'] }.zero?
      checked += 1
    end
  end
  invalid_driver = talk.call({'method'=>'GET','path'=>'not-an-absolute-path'})
  raise 'driver accepted invalid request target' unless invalid_driver['status'] == 400
  checked += 1
  # Metamorphic holdouts: commuting disjoint loans and exact reversal.
  sequences = [
    [['Ada', 'Bob', 12.25], ['Cal', 'Dee', 7.50]],
    [['Cal', 'Dee', 7.50], ['Ada', 'Bob', 12.25]]
  ]
  states = sequences.map do |sequence|
    talk.call({'reset' => %w[Ada Bob Cal Dee]})
    sequence.each do |lender, borrower, amount|
      r = talk.call({'method' => 'POST', 'path' => '/iou',
                     'body' => {'lender' => lender, 'borrower' => borrower, 'amount' => amount}})
      raise "metamorphic transaction failed #{r}" unless r['status'] == 200
      checked += 1
    end
    checked += 1
    normalized_users(talk.call({'method' => 'GET', 'path' => '/users'}).fetch('body').fetch('users'))
  end
  raise 'disjoint transactions do not commute' unless states[0] == states[1]
  talk.call({'reset' => %w[Ada Bob]})
  [['Ada','Bob',19.75],['Bob','Ada',19.75]].each do |lender,borrower,amount|
    r=talk.call({'method'=>'POST','path'=>'/iou','body'=>{'lender'=>lender,'borrower'=>borrower,'amount'=>amount}})
    raise 'reverse IOU failed' unless r['status']==200
    checked+=1
  end
  cancelled=normalized_users(talk.call({'method'=>'GET','path'=>'/users'}).fetch('body').fetch('users'))
  raise 'reversal did not cancel obligations' unless cancelled.all? { |u| u['balance']==0 && u['owes'].empty? && u['owed_by'].empty? }
  checked+=1
  stdin.close
  raise 'driver exited unsuccessfully' unless wait.value.success?
end
puts "Ruby replay oracle: #{histories} histories, #{checked} real Go HTTP requests verified, global zero-sum invariant PASS"
