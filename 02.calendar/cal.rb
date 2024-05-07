#!/usr/bin/env ruby

require 'date'
require 'optparse'

today = Date.today
year = today.year
month = today.month

def make_cal_header(year, month)
<<HEADER
       #{month}月 #{year}
日 月 火 水 木 金 土
HEADER
end

def make_cal_body(year, month)
  content = ""
  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1)
  
  first_day.step(last_day, 1) do |d|
    day = d.day.to_s
    day.prepend(" ") if day.length == 1
    d.saturday? ? day.concat(" ", "\n") : day.concat(" ")
    content << day
  end

  content.prepend(" " * first_day.wday * 3)
end

options = OptionParser.new do |opts|
  opts.banner = "Usage: ./cal.rb [options]"

  opts.on('-y YEAR', 'year from 1970 to 2100') do |y|
    if (1970..2100).include?(y.to_i)
      year = y.to_i
    else
      raise OptionParser::InvalidArgument, "invalid year"
    end
  end

  opts.on('-m MONTH', 'month from 1 to 12') do |m|
    if (1..12).include?(m.to_i)
      month = m.to_i
    else
      raise OptionParser::InvalidArgument, "invalid month"
    end
  end
end

begin
  options.parse!(ARGV)
rescue OptionParser::ParseError => e
  puts e.message
  puts options.help
  exit
end

puts make_cal_header(year, month) + make_cal_body(year, month)
