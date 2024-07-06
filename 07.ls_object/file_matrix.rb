# frozen_string_literal: true

class FileMatrix
  def initialize(file_names, max_column)
    @file_names = file_names
    @max_column = max_column
  end

  def formatted_matrix
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
end
