# frozen_string_literal: true
# SPDX-License-Identifier: MIT
# Behaviorally incorrect reference with same public interface for RED.
require_relative 'spending'
module NinjaSpending
  def self.detect(_current, _previous)
    []
  end
end
