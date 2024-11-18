# frozen_string_literal: true

require_relative 'file'

module LS
  class FileList
    attr_reader :files

    def initialize(file_names)
      @files = file_names.map { |file_name| LS::File.new(file_name) }
    end

    def current_directory_stats
      file_stats_array = files.map { |file| file.stat }
      file_stats_array_per_column = file_stats_array.transpose

      max_length_per_column = {}
      file_stats_array_per_column.each_with_index do |file_stats, idx|
        max_length_per_column[idx] = file_stats.max_by(&:length).length
      end

      file_stats_array.map.with_index do |file_stats, idx|
        justify_file_stats = file_stats.map.with_index do
          _1.rjust(max_length_per_column[_2])
        end

        file_names = []
        file_names[idx] = (justify_file_stats << file_names[idx]).join(' ')
      end
    end

    def show(max_column, long_format: false)
      matrix(max_column, long_format:).map { |m| m.join.rstrip!.concat("\n") }.join
    end

    private

    def matrix(max_column, long_format: false)
      num_of_files = files.size

      formatted_files = long_format ? current_directory_stats : files.map { |file| file.file_name }

      num_of_display_rows = (num_of_files % max_column).zero? ? num_of_files.div(max_column) : num_of_files.div(max_column) + 1

      formatted_files.each_slice(num_of_display_rows).map do |matrix_col|
        matrix_col.fill('', matrix_col.size..(num_of_display_rows - 1)) unless matrix_col.size == num_of_display_rows
        longest_file_name = matrix_col.max_by(&:length).length

        matrix_col.map do |file_name|
          diff = longest_file_name - file_name.length
          "#{file_name}#{' ' * diff if diff.positive?}#{' ' * 4}"
        end
      end.transpose
    end
  end
end
