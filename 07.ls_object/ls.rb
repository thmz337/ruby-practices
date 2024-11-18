#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'
require 'optparse'

require_relative 'file_list'

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

max_column = params.include?(:l) ? 1 : 3

file_names = params.include?(:a) ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
file_names.reverse! if params.include?(:r)

files = LS::FileList.new(file_names)

puts files.show(max_column, long_format: params.include?(:l))
