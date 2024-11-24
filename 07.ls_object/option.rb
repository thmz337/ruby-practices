# frozen_string_literal: true

require 'optparse'

module LS
  class OptionParser
    BANNER = 'Usage: ./ls.rb [options]'
    OPTION_CHOICES = {
      '-a': 'Include directory entries whose names begin with a dot (‘.’).',
      '-r': 'Display files in reverse order.',
      '-l': 'List files in the long format.'
    }

    attr_reader :options

    def initialize(argv)
      @options = parse(argv)
    end

    def parse(argv)
      parser = ::OptionParser.new do |opts|
        opts.banner = BANNER
        OPTION_CHOICES.each { |name, description|  opts.on(name, description) }
      end

      begin
        opts = {}
        parser.parse!(ARGV, into: opts)
        opts
      rescue ::OptionParser::ParseError => e
        puts e.message
        puts opts.help
        exit
      end
    end
  end
end
