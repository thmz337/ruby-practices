#!/usr/bin/env ruby

require 'date'
require 'optparse'

# カレンダーとして表示する対象の年月
# デフォルトで今日の年月を表示するようにする
year = Date.today.year
month = Date.today.month

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
    # 1桁の日付の幅を2桁の日付に合わせるために、半角スペースを付与する
    day.prepend(" ") if day.length == 1
    d.saturday? ? day.concat(" ", "\n") : day.concat(" ")
    content << day
  end

  # 月初が日曜日の場合以外は、その分先頭にスペースを入れる
  content.prepend(" " * first_day.wday * 3)
end

# オプションの設定と処理
options = OptionParser.new do |opts|
  opts.banner = "Usage: ./cal.rb [options]"

  opts.on('-y YEAR', '', 'year from 1970 to 2100') do |y|
    if (1970..2100).include?(y.to_i)
      year = y.to_i
    else
      raise OptionParser::InvalidArgument, "invalid year"
    end
  end
  
  opts.on('-m MONTH', '', 'month from 1 to 12') do |m|
    if (1..12).include?(m.to_i)
      month = m.to_i
    else
      raise OptionParser::InvalidArgument, "invalid month"
      exit
    end
  end
end

# オプションをパースする
# 無効なオプションを指定した時は、エラーメッセージとヘルプを出力して終了する
begin
  options.parse!(ARGV)
rescue OptionParser::ParseError => e
  puts e.message
  puts options.help
  exit
end

# カレンダーのヘッダーとコンテンツを連結し、表示する
puts make_cal_header(year, month) + make_cal_body(year, month)
