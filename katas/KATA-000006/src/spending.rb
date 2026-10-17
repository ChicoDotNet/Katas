# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'date'
module NinjaSpending
  CATEGORIES = %w[entertainment golf groceries restaurants travel].freeze
  Payment = Struct.new(:category, :cents, :description, keyword_init: true) do
    def initialize(category:, cents:, description: '')
      raise ArgumentError, 'invalid category' unless CATEGORIES.include?(category)
      raise ArgumentError, 'cents must be a nonnegative Integer' unless cents.is_a?(Integer) && cents >= 0
      super
      freeze
    end
  end
  Alert = Struct.new(:category, :current_cents, :previous_cents, keyword_init: true)
  def self.detect(current, previous)
    now_totals = Hash.new(0)
    old_totals = Hash.new(0)
    current.each { |payment| now_totals[payment.category] += payment.cents }
    previous.each { |payment| old_totals[payment.category] += payment.cents }
    now_totals.sort.filter_map do |category, amount|
      last_month = old_totals[category]
      if amount.positive? && (last_month.zero? || amount * 2 >= last_month * 3)
        Alert.new(category: category, current_cents: amount, previous_cents: last_month)
      end
    end
  end
  def self.compose(alerts)
    return nil if alerts.empty?
    total_cents = alerts.sum(&:current_cents)
    dollars = ->(cents) { format('$%d.%02d', cents / 100, cents % 100) }
    details = alerts.map { |entry| "* You spent #{dollars.call(entry.current_cents)} on #{entry.category}" }
    {
      subject: "Unusual spending of #{dollars.call(total_cents)} detected!",
      body: (['Hello card user!', '', 'We found unusual spending in these categories:', ''] + details + ['', 'Sincerely,', 'Card insights']).join("\n")
    }
  end
  class Service
    def initialize(source:, sender:)
      @source, @sender = source, sender
    end
    def run(user_id:, month:)
      raise ArgumentError, 'month must be a Date' unless month.is_a?(Date)
      current = @source.payments(user_id, Date.new(month.year, month.month, 1))
      previous = @source.payments(user_id, Date.new(month.year, month.month, 1) << 1)
      alerts = NinjaSpending.detect(current, previous)
      mail = NinjaSpending.compose(alerts)
      @sender.deliver(user_id, mail) if mail
      alerts
    end
  end
end
