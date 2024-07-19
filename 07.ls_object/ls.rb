#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'
require 'optparse'

require_relative 'file_stat'

class LS

  def initialize(options = {})
    @options = options
    @max_column = @options.include?(:l) ? 1 : 3
  end

  def formatted_matrix
    @file_names = current_directory_stats
    num_of_files = @file_names.size

    num_of_display_cols = (num_of_files % @max_column).zero? ? num_of_files.div(@max_column) : num_of_files.div(@max_column) + 1

    @file_names.each_slice(num_of_display_cols).map do |matrix_row|
      matrix_row.fill('', matrix_row.size..(num_of_display_cols - 1)) unless matrix_row.size == num_of_display_cols
      longest_file_name = matrix_row.max_by(&:length).length

      matrix_row.map do |file_name|
        diff = longest_file_name - file_name.length
        "#{file_name}#{' ' * diff if diff.positive?}#{' ' * 4}"
      end
    end.transpose
  end

  private

  def current_directory_stats
    file_names = @options.include?(:a) ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    file_names.reverse! if @options.include?(:r)

    return file_names unless @options.include?(:l)

    file_informations_array = file_names.map do |file_name|
      FileStat.new(file_name).stat
    end

    file_informations_array_per_column = file_informations_array.transpose

    max_element_length_per_column = {}
    file_informations_array_per_column.each_with_index do |file_informations, idx|
      max_element_length_per_column[idx] = file_informations.max_by(&:length).length
    end

    file_informations_array.map.with_index do |file_informations, idx|
      justify_file_informations = file_informations.map.with_index do
        _1.rjust(max_element_length_per_column[_2])
      end

      file_names[idx] = (justify_file_informations << file_names[idx]).join(' ')
    end
  end
end

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

puts LS.new(params).formatted_matrix.map { |m| m.join.rstrip!.concat("\n") }.join
