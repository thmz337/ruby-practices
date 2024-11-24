#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'

require_relative 'option'
require_relative 'file_list'

options = LS::OptionParser.new(ARGV).options

max_column = options.include?(:l) ? 1 : 3

file_names = options.include?(:a) ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
file_names.reverse! if options.include?(:r)

files = LS::FileList.new(file_names)

puts files.show(max_column, long_format: options.include?(:l))
