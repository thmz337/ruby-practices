#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'
require 'optparse'

options = OptionParser.new do |opts|
  opts.banner = 'Usage: ./ls.rb [options]'

  opts.on('-a', 'Include directory entries whose names begin with a dot (‘.’).')
  opts.on('-r', 'Display files in reverse order.')
  opts.on('-l', 'Display files in reverse order.')
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

FILE_TYPE_ABBRV = {
  'file' => '-',
  'directory' => 'd',
  'characterSpecial' => 'c',
  'blockSpecial' => 'b',
  'fifo' => 'p',
  'link' => 'l',
  'socket' => 's'
}.freeze

FILE_PERMISSION_TEXT = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

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

def file_mode_text(stat)
  type = FILE_TYPE_ABBRV[stat.ftype]
  mode = stat.mode.to_s(8).length == 5 ? "0#{stat.mode.to_s(8)}" : stat.mode.to_s(8)
  "#{type}#{mode[3..5].chars.map { |c| FILE_PERMISSION_TEXT[c] }.join}"
end

def max_column_element_length(column_elements)
  column_elements.max_by(&:length)
end

file_names = current_directory_file_names(params)

if params.include?(:l)
  file_stats_array = file_names.map do |file_name|
    stat = File.lstat(file_name)
    [
      file_mode_text(stat),
      stat.nlink.to_s,
      Etc.getpwuid(stat.uid).name,
      Etc.getgrgid(stat.gid).name,
      stat.size.to_s,
      stat.mtime.month.to_s,
      stat.mtime.day.to_s,
      stat.mtime.strftime('%H:%M')
    ]
  end

  group_elements_per_column = file_stats_array.transpose
  max_element_length_per_column = {}
  group_elements_per_column.each_with_index do |elm, idx|
    max_element_length_per_column[idx] = elm.max_by(&:length).length
  end

  justify_file_stats_array = file_stats_array.map do |stat_elm|
    stat_elm.map.with_index do |elm, idx|
      elm.rjust(max_element_length_per_column[idx])
    end
  end

  file_names = file_names.map.with_index do |file_name, idx|
    (justify_file_stats_array[idx] << file_name).join(' ')
  end
end

file_names.reverse! if params.include?(:r)

unless file_names.empty?
  matrix = make_matrix(file_names)
  display_matrix = matrix.transpose
  display_text = make_display_text(display_matrix)
  puts display_text
end
