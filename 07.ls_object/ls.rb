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

def formatted_matrix(file_names, max_column, long_format: false)
  files = current_directory_stats(file_names, long_format:)
  num_of_files = files.size

  num_of_display_rows = (num_of_files % max_column).zero? ? num_of_files.div(max_column) : num_of_files.div(max_column) + 1

  files.each_slice(num_of_display_rows).map do |matrix_col|
    matrix_col.fill('', matrix_col.size..(num_of_display_rows - 1)) unless matrix_col.size == num_of_display_rows
    longest_file_name = matrix_col.max_by(&:length).length

    matrix_col.map do |file_name|
      diff = longest_file_name - file_name.length
      "#{file_name}#{' ' * diff if diff.positive?}#{' ' * 4}"
    end
  end.transpose
end

def current_directory_stats(file_names, long_format: false)
  return file_names unless long_format

  file_stats_array = LS::FileList.new(file_names).stats
  file_stats_array_per_column = file_stats_array.transpose

  max_length_per_column = {}
  file_stats_array_per_column.each_with_index do |file_stats, idx|
    max_length_per_column[idx] = file_stats.max_by(&:length).length
  end

  file_stats_array.map.with_index do |file_stats, idx|
    justify_file_stats = file_stats.map.with_index do
      _1.rjust(max_length_per_column[_2])
    end

    file_names[idx] = (justify_file_stats << file_names[idx]).join(' ')
  end
end

max_column = params.include?(:l) ? 1 : 3

file_names = params.include?(:a) ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
file_names.reverse! if params.include?(:r)

puts formatted_matrix(file_names, max_column, long_format: params.include?(:l)).map { |m| m.join.rstrip!.concat("\n") }.join
