# frozen_string_literal: true

class FileNamesList
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

  def initialize(options = {})
    @options = options
  end

  def current_directory
    file_names = @options.include?(:a) ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    file_names.reverse! if @options.include?(:r)

    return unless @options.include?(:l)

    file_informations_array = file_names.map do |file_name|
      get_file_stats(file_name)
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

  private

  def convert_mode_to_octal_string(mode)
    mode.to_s(8)
  end

  def file_mode_text(stat)
    type = FILE_TYPE_ABBRV[stat.ftype]
    octalized_file_mode = convert_mode_to_octal_string(stat.mode)
    file_mode = octalized_file_mode.length == 5 ? "0#{octalized_file_mode}" : octalized_file_mode
    "#{type}#{file_mode[3..5].chars.map { |c| FILE_PERMISSION_TEXT[c] }.join}"
  end

  def get_file_stats(file_name)
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
end
