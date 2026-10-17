# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'json'
require_relative 'spending'
input = JSON.parse(STDIN.read)
result = input.map do |scenario|
  now = scenario.fetch('current').map { |p| NinjaSpending::Payment.new(category: p.fetch('category'), cents: p.fetch('cents')) }
  old = scenario.fetch('previous').map { |p| NinjaSpending::Payment.new(category: p.fetch('category'), cents: p.fetch('cents')) }
  NinjaSpending.detect(now, old).map do |entry|
    { category: entry.category, current_cents: entry.current_cents, previous_cents: entry.previous_cents }
  end
end
puts JSON.generate(result)
