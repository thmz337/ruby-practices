# frozen_string_literal: true

module LS
  class File
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

    attr_reader :file_name, :file_mode, :nlink, :user, :group, :size, :mod_month, :mod_day, :mod_time

    def initialize(file_name)
      raw_stat = ::File.lstat(file_name)
      @file_name = file_name
      @file_mode = file_mode_text(raw_stat)
      @nlink = raw_stat.nlink.to_s
      @user = Etc.getpwuid(raw_stat.uid).name
      @group = Etc.getgrgid(raw_stat.gid).name
      @size = raw_stat.size.to_s
      @mod_month = raw_stat.mtime.month.to_s
      @mod_day = raw_stat.mtime.day.to_s
      @mod_time = raw_stat.mtime.strftime('%H:%M')
    end

    def stat
      [file_mode, nlink, user, group, size, mod_month, mod_day, mod_time]
    end

    private

    def convert_file_mode_to_octal_string(mode)
      mode.to_s(8)
    end

    def file_mode_text(stat)
      type = FILE_TYPE_ABBRV[stat.ftype]
      octalized_file_mode = convert_file_mode_to_octal_string(stat.mode)
      file_mode = octalized_file_mode.length == 5 ? "0#{octalized_file_mode}" : octalized_file_mode
      "#{type}#{file_mode[3..5].chars.map { |c| FILE_PERMISSION_TEXT[c] }.join}"
    end
  end
end
