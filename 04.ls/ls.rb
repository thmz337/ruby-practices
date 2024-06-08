#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

MAX_COLUMN = 3

def current_directory_file_names(options = {})
  options.include?(:a) ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
end

def make_matrix(file_names)
  num_of_file_names = file_names.size

  num_of_cols = (num_of_file_names % MAX_COLUMN).zero? ? num_of_file_names.div(MAX_COLUMN) : num_of_file_names.div(MAX_COLUMN) + 1

  file_names.each_slice(num_of_cols).map do |matrix_row|
    matrix_row.fill('', matrix_row.size..(num_of_cols - 1)) unless matrix_row.size == num_of_cols
    longest_file_name = matrix_row.max_by(&:length).length

    matrix_row.map do |file_name|
      diff = longest_file_name - file_name.length
      "#{file_name}#{' ' * diff if diff.positive?}#{' ' * 4}"
    end
  end
end

def make_display_text(matrix)
  matrix.map { |m| m.join.rstrip!.concat("\n") }.join
end

options = OptionParser.new do |opts|
  opts.banner = 'Usage: ./ls.rb [options]'

  opts.on('-a', 'Include directory entries whose names begin with a dot (‘.’).')
end

begin
  params = {}
  options.parse!(ARGV, into: params)
rescue OptionParser::ParseError => e
  puts e.message
  puts options.help
  exit
end

file_names = current_directory_file_names(params)

unless file_names.empty?
  matrix = make_matrix(file_names)
  display_matrix = matrix.transpose
  display_text = make_display_text(display_matrix)
  puts display_text
end
