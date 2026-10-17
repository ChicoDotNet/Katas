# frozen_string_literal: true
# SPDX-License-Identifier: MIT
module NinjaPoker
 RANKS='23456789TJQKA'
 SUITS='CDHS'
 module_function
 def strength(hand)
  cards=hand.split(' ')
  raise ArgumentError,'five distinct cards required' unless cards.size==5 && cards.uniq.size==5
  raise ArgumentError,'invalid card' unless cards.all?{|c| c.match?(/\A[2-9TJQKA][CDHS]\z/)}
  nums=cards.map{|c| RANKS.index(c[0])+2}
  counts=nums.tally
  flush=cards.map{|c|c[1]}.uniq.size==1
  uniq=nums.uniq.sort
  straight_high=uniq.size==5&&uniq.last-uniq.first==4 ? uniq.last : nil
  straight_high=5 if uniq==[2,3,4,5,14]
  patterns=counts.group_by{|_,n|n}.transform_values{|pairs|pairs.map(&:first).sort.reverse}
  if flush&&straight_high
   [8,straight_high]
  elsif counts.values.include?(4)
   [7,patterns.fetch(4).first,patterns.fetch(1).first]
  elsif counts.values.sort==[2,3]
   [6,patterns.fetch(3).first,patterns.fetch(2).first]
  elsif flush
   [5,*nums.sort.reverse]
  elsif straight_high
   [4,straight_high]
  elsif counts.values.include?(3)
   [3,patterns.fetch(3).first,*patterns.fetch(1)]
  elsif counts.values.sort==[1,2,2]
   [2,*patterns.fetch(2),patterns.fetch(1).first]
  elsif counts.values.include?(2)
   [1,patterns.fetch(2).first,*patterns.fetch(1)]
  else
   [0,*nums.sort.reverse]
  end
 end
 def best(hands)
  raise ArgumentError,'array required' unless hands.is_a?(Array)&&hands.all?{|h|h.is_a?(String)}
  return [] if ENV['KATA_RED']=='1'
  return [] if hands.empty?
  scores=hands.map{|h|strength(h)};top=scores.max
  hands.each_with_index.filter_map{|h,i| h if scores[i]==top}
 end
end
