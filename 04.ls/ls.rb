#!/usr/bin/env ruby

# frozen_string_literal: true

MAX_COLUMN = 3

def current_directory_files
  Dir.glob('*')
end

def make_matrix(files)
  number_of_files = files.size

  col = (number_of_files % MAX_COLUMN).zero? ? number_of_files.div(MAX_COLUMN) : number_of_files.div(MAX_COLUMN) + 1

  files.each_slice(col).map do |fs|
    fs.fill('', fs.size..(col - 1)) unless fs.size == col
    longest_file_name = fs.max_by(&:length).length

    fs.map do |f|
      fd = f.dup
      diff = longest_file_name - f.length
      fd.concat(' ' * diff) if diff.positive?
      fd.concat(' ' * 4)
    end
  end
end

def make_display_text(matrix)
  matrix.map { |m| m.join.rstrip!.concat("\n") }.join
end

files = current_directory_files

unless files.empty?
  matrix = make_matrix(files)
  display_matrix = matrix.transpose
  display_text = make_display_text(display_matrix)
  puts display_text
end
