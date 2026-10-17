# frozen_string_literal: true
require 'minitest/autorun'
require 'date'
require_relative '../src/spending'
require_relative '../src/spending_red' if ENV['KATA_RED'] == '1'

class SpendingTest < Minitest::Test
  def pmt(category, cents)
    NinjaSpending::Payment.new(category: category, cents: cents)
  end
  def test_exact_fifty_percent_boundary_and_composition
    alerts = NinjaSpending.detect([pmt('travel', 15_000)], [pmt('travel', 10_000)])
    assert_equal [['travel', 15_000, 10_000]], alerts.map { |x| [x.category, x.current_cents, x.previous_cents] }, 'exact threshold must alert'
    mail = NinjaSpending.compose(alerts)
    assert_equal 'Unusual spending of $150.00 detected!', mail[:subject]
    assert_includes mail[:body], '* You spent $150.00 on travel'
  end
  def test_below_boundary_and_equal_amount_do_not_alert
    assert_empty NinjaSpending.detect([pmt('travel', 14_999)], [pmt('travel', 10_000)])
    assert_empty NinjaSpending.detect([pmt('travel', 10_000)], [pmt('travel', 10_000)])
  end
  def test_new_category_and_zero_previous
    assert_equal ['golf'], NinjaSpending.detect([pmt('golf', 1)], []).map(&:category)
    assert_empty NinjaSpending.detect([pmt('golf', 0)], [])
  end
  def test_multiple_payments_group_by_category_and_order
    alerts = NinjaSpending.detect(
      [pmt('travel', 6000), pmt('groceries', 5000), pmt('travel', 4000), pmt('golf', 100)],
      [pmt('travel', 5000), pmt('groceries', 4000), pmt('golf', 100)])
    assert_equal %w[travel], alerts.map(&:category)
    assert_equal 10_000, alerts.first.current_cents
  end
  def test_input_validation
    assert_raises(ArgumentError) { pmt('airfare', 100) }
    assert_raises(ArgumentError) { pmt('travel', -1) }
    assert_raises(ArgumentError) { pmt('travel', 12.5) }
  end
  class MemorySource
    attr_reader :calls
    def initialize(periods)
      @periods = periods
      @calls = []
    end
    def payments(user, month)
      @calls << [user, month]
      @periods.fetch(month, [])
    end
  end
  class MemorySender
    attr_reader :messages
    def initialize; @messages = []; end
    def deliver(user, mail); @messages << [user, mail]; end
  end
  def test_service_uses_month_boundaries_and_one_message
    january = Date.new(2026, 1, 1)
    december = Date.new(2025, 12, 1)
    source = MemorySource.new(january => [pmt('travel', 150)], december => [pmt('travel', 100)])
    sender = MemorySender.new
    found = NinjaSpending::Service.new(source: source, sender: sender).run(user_id: 'u1', month: Date.new(2026, 1, 17))
    assert_equal [january, december], source.calls.map(&:last)
    assert_equal 1, found.length
    assert_equal 1, sender.messages.length
  end
  def test_no_email_for_no_alerts
    source = MemorySource.new({})
    sender = MemorySender.new
    assert_empty NinjaSpending::Service.new(source: source, sender: sender).run(user_id: 'u', month: Date.new(2026, 10, 3))
    assert_empty sender.messages
  end
end
