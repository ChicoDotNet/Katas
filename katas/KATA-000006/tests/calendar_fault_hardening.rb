# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'minitest/autorun'
require 'date'
require ENV.fetch('SPENDING_IMPL', File.expand_path('../src/spending.rb', __dir__))

class CalendarFaultHardening < Minitest::Test
  Payment = NinjaSpending::Payment
  def payment(category, cents)
    Payment.new(category: category, cents: cents)
  end
  class Source
    attr_reader :calls
    def initialize(current_month:, previous_month:, current:, previous:, fail_at: nil)
      @current_month, @previous_month = current_month, previous_month
      @current, @previous, @fail_at = current, previous, fail_at
      @calls = []
    end
    def payments(user, month)
      @calls << [user, month]
      raise IOError, 'injected payment-source outage' if @calls.length == @fail_at
      return @current if month == @current_month
      return @previous if month == @previous_month
      raise ArgumentError, "unexpected month #{month}"
    end
  end
  class Sender
    attr_reader :messages
    def initialize(fail: false)
      @fail = fail
      @messages = []
    end
    def deliver(user, message)
      raise IOError, 'injected mail outage' if @fail
      @messages << [user, message]
    end
  end
  def test_calendar_rollover_all_months_and_days
    (2020..2030).each do |year|
      (1..12).each do |month|
        [1, 15, 28].each do |day|
          current = Date.new(year, month, 1)
          previous = month == 1 ? Date.new(year - 1, 12, 1) : Date.new(year, month - 1, 1)
          source = Source.new(current_month: current, previous_month: previous,
                              current: [payment('travel', 150)], previous: [payment('travel', 100)])
          sender = Sender.new
          result = NinjaSpending::Service.new(source: source, sender: sender)
                                         .run(user_id: 'account-7', month: Date.new(year, month, day))
          assert_equal [['account-7', current], ['account-7', previous]], source.calls
          assert_equal ['travel'], result.map(&:category)
          assert_equal 1, sender.messages.length
          assert_equal 'account-7', sender.messages[0][0]
          assert_equal 'Unusual spending of $1.50 detected!', sender.messages[0][1][:subject]
        end
      end
    end
  end
  def test_faults_and_invalid_inputs_never_send_mail
    current, previous = Date.new(2026, 1, 1), Date.new(2025, 12, 1)
    [1, 2].each do |failed_read|
      source = Source.new(current_month: current, previous_month: previous,
                          current: [payment('travel', 150)], previous: [payment('travel', 100)], fail_at: failed_read)
      sender = Sender.new
      assert_raises(IOError) { NinjaSpending::Service.new(source: source, sender: sender)
                              .run(user_id: 'u', month: current) }
      assert_empty sender.messages
      assert_equal failed_read, source.calls.length
    end
    source = Source.new(current_month: current, previous_month: previous,
                        current: [payment('travel', 150)], previous: [payment('travel', 100)])
    sender = Sender.new(fail: true)
    assert_raises(IOError) { NinjaSpending::Service.new(source: source, sender: sender)
                            .run(user_id: 'u', month: current) }
    assert_empty sender.messages
    source2 = Source.new(current_month: current, previous_month: previous, current: [], previous: [])
    sender2 = Sender.new
    assert_empty NinjaSpending::Service.new(source: source2, sender: sender2).run(user_id: 'u', month: current)
    assert_empty sender2.messages
    source3 = Source.new(current_month: current, previous_month: previous, current: [], previous: [])
    assert_raises(ArgumentError) { NinjaSpending::Service.new(source: source3, sender: Sender.new)
                                   .run(user_id: 'u', month: '2026-01') }
    assert_empty source3.calls
  end
  def test_threshold_equality_and_metamorphic_split_permutation_scale
    rng = Random.new(20_261_029)
    (1..500).each do |n|
      exact = NinjaSpending.detect([payment('travel', 3 * n)], [payment('travel', 2 * n)])
      below = NinjaSpending.detect([payment('travel', 3 * n - 1)], [payment('travel', 2 * n)])
      assert_equal ['travel'], exact.map(&:category)
      assert_empty below
    end
    300.times do
      current = Array.new(rng.rand(1..15)) { payment(NinjaSpending::CATEGORIES.sample(random: rng), rng.rand(0..100_000)) }
      previous = Array.new(rng.rand(1..15)) { payment(NinjaSpending::CATEGORIES.sample(random: rng), rng.rand(0..100_000)) }
      baseline = NinjaSpending.detect(current, previous).map { |a| [a.category, a.current_cents, a.previous_cents] }
      shuffled = NinjaSpending.detect(current.shuffle(random: rng), previous.shuffle(random: rng))
      assert_equal baseline, shuffled.map { |a| [a.category, a.current_cents, a.previous_cents] }
      split = current.flat_map do |p|
        half = p.cents / 2
        [payment(p.category, half), payment(p.category, p.cents - half)]
      end
      assert_equal baseline, NinjaSpending.detect(split, previous).map { |a| [a.category, a.current_cents, a.previous_cents] }
      doubled = NinjaSpending.detect(current.map { |p| payment(p.category, p.cents * 2) },
                                     previous.map { |p| payment(p.category, p.cents * 2) })
      assert_equal baseline.map { |category, now, old| [category, now * 2, old * 2] },
                   doubled.map { |a| [a.category, a.current_cents, a.previous_cents] }
    end
  end
end
