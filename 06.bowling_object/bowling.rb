#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './frame'
require_relative './game'
require_relative './shot'

scores = ARGV[0].split(',')

game = Game.new(scores)
puts game.points
