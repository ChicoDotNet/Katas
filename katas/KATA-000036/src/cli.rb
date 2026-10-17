# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require 'json'
require_relative 'poker'
puts JSON.generate(JSON.parse(STDIN.read).map{|hands|NinjaPoker.best(hands)})
