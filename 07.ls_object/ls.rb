#!/usr/bin/env ruby

# frozen_string_literal: true

require 'etc'

require_relative 'option'
require_relative 'file_list'

options = LS::OptionParser.new(ARGV).options

files = LS::FileList.new(options)

puts files.show
