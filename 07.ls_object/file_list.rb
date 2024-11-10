# frozen_string_literal: true

require_relative 'file'

module LS
  class FileList
    attr_reader :stats

    def initialize(file_names)
      @stats = file_names.map { |file_name| LS::File.new(file_name).stat }
    end
  end
end
