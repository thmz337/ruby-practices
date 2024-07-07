#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'tempfile'

ENV['POSIXLY_CORRECT'] = '1'

def count_lines(input)
  input.readlines.size
end

def count_words(input)
  input.read.split.size
end

def count_chars(input)
  input.each_char.count
end

OPTION_METHODS_TABLE = {
  l: method('count_lines'),
  w: method('count_words'),
  c: method('count_chars')
}.freeze

def append_number_of_spaces(text, num)
  "#{"\s" * num}#{text}"
end

def get_statuses_from_file(file_name, params)
  statuses = {}

  File.open(file_name) do |file|
    params.each_key do |k|
      statuses[k] = OPTION_METHODS_TABLE[k].call(file)
      file.rewind
    end
  end

  statuses[:file_name] = file_name
  statuses
end

def get_statuses_from_stdin(params)
  statuses = {}

  Tempfile.create('stdin_content') do |file|
    file.write($stdin.read)
    file.rewind

    params.each_key do |k|
      statuses[k] = OPTION_METHODS_TABLE[k].call(file)
      file.rewind
    end
  end

  statuses
end

def max_content_length(array)
  array.map(&:to_s).map(&:size).max
end

options = OptionParser.new do |opts|
  opts.banner = 'Usage: ./wc.rb [options]'

  opts.on('-l', 'The number of lines in each input file is written to the standard output.')
  opts.on('-w', 'The number of words in each input file is written to the standard output.')
  opts.on('-c', ' The number of bytes in each input file is written to the standard output.')
end

begin
  params = {}
  options.parse!(ARGV, into: params)
rescue OptionParser::ParseError => e
  puts e.message
  puts options.help
  exit
end

params = { l: true, w: true, c: true } if params.empty?
file_statuses_array = []

if ARGV.empty?
  file_statuses_array << get_statuses_from_stdin(params)
else
  ARGV.each do |file_name|
    file_statuses_array << get_statuses_from_file(file_name, params)

  rescue Errno::ENOENT => e
    file_statuses_array << { error: "wc: #{file_name}: open: No such file or directory" }
    next
  end

  if file_statuses_array.length > 1
    total_statuses = {}
    params.each_key do |k|
      total_statuses[k] = file_statuses_array.map { |file_statuses| file_statuses[k] }.reject(&:nil?).sum
    end
    total_statuses[:file_name] = 'total'
    file_statuses_array << total_statuses
  end
end

max_content_length_by_column = {}
params.each_key do |k|
  file_statuses_by_column = file_statuses_array.map { |file_statuses| file_statuses[k] }
  max_content_length_by_column[k] = max_content_length(file_statuses_by_column)
end

file_statuses_array.each do |file_statuses|
  if file_statuses.include?(:error)
    puts file_statuses.values_at(:error)
  else
    justified_file_statuses = []
    file_statuses.each do |key, file_status|
      justified_file_statuses << if key == :file_name
                                   " #{file_status}"
                                 else
                                   "     #{append_number_of_spaces(file_status, max_content_length_by_column[key] - file_status.to_s.length)}"
                                 end
    end
    puts justified_file_statuses.join
  end
end
