#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'
require 'optparse'

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

def convert_mode_to_octal_string(mode)
  mode.to_s(8)
end

def file_mode_text(stat)
  type = FILE_TYPE_ABBRV[stat.ftype]
  octalized_file_mode = convert_mode_to_octal_string(stat.mode)
  file_mode = octalized_file_mode.length == 5 ? "0#{octalized_file_mode}" : octalized_file_mode
  "#{type}#{file_mode[3..5].chars.map { |c| FILE_PERMISSION_TEXT[c] }.join}"
end

file_names = current_directory_file_names(params)

if params.include?(:l)
  file_informations_array = file_names.map do |file_name|
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

  group_file_informations_array_per_column = file_informations_array.transpose
  max_element_length_per_column = {}
  group_file_informations_array_per_column.each_with_index do |file_informations, idx|
    max_element_length_per_column[idx] = file_informations.max_by(&:length).length
  end

  justify_file_informations_array = file_informations_array.map do |file_informations|
    file_informations.map.with_index do
      _1.rjust(max_element_length_per_column[_2])
    end
  end

  file_names = file_names.map.with_index do |file_name, idx|
    (justify_file_informations_array[idx] << file_name).join(' ')
  end
end

file_names.reverse! if params.include?(:r)

unless file_names.empty?
  matrix = make_matrix(file_names)
  display_matrix = matrix.transpose
  display_text = make_display_text(display_matrix)
  puts display_text
end
