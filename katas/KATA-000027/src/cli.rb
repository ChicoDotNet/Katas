#!/usr/bin/env ruby
# frozen_string_literal: true
# SPDX-License-Identifier: MIT
require_relative(ENV.fetch('TENNIS_SOURCE', 'tennis'))

STDIN.each_line do |line|
  sequence = line.chomp
  sequence = '' if sequence == '-'
  game = Tennis::Game.new
  begin
    sequence.each_char { |point| game = game.point(point) }
    puts game.score
  rescue Tennis::InvalidPoint
    puts 'ERR:invalid'
  rescue Tennis::GameOver
    puts 'ERR:finished'
  end
end
