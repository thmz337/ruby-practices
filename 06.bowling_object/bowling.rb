#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './frame'
require_relative './game'
require_relative './shot'

scores = ARGV[0].split(',')

def make_shots(scores)
  shots = []
  scores.map do |score|
    shots << Shot.make_shot(score)
    shots << 0 if score == 'X'
  end
  shots
end

def last_frame_three_throws?(scores)
  shots = make_shots(scores[0...-3])
  shots.size.even?
end

if last_frame_three_throws?(scores)
  last_three_throws = scores[-3..].map do |s|
    s == 'X' ? 10 : s.to_i
  end
  shot_pairs = make_shots(scores[0...-3]).each_slice(2).to_a << last_three_throws
else
  shot_pairs = make_shots(scores).each_slice(2).to_a
end

frames = shot_pairs.map do |shot_pair|
  Frame.new(shot_pair)
end

game = Game.new(frames)
puts game.points
