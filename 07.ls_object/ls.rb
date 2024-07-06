#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'
require 'optparse'

require_relative './file_matrix'
require_relative './file_names_list'

options = OptionParser.new do |opts|
  opts.banner = 'Usage: ./ls.rb [options]'

  opts.on('-a', 'Include directory entries whose names begin with a dot (‘.’).')
  opts.on('-r', 'Display files in reverse order.')
  opts.on('-l', 'List files in the long format.')
end

begin
  params = {}
  options.parse!(ARGV, into: params)
rescue OptionParser::ParseError => e
  puts e.message
  puts options.help
  exit
end

MAX_COLUMN = params.include?(:l) ? 1 : 3

file_names = FileNamesList.new(params).current_directory
file_matrix = FileMatrix.new(file_names, MAX_COLUMN).formatted_matrix
puts file_matrix.map { |m| m.join.rstrip!.concat("\n") }.join
