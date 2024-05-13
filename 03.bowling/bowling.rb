#!/usr/bin/env ruby
# frozen_string_literal: true

def make_scores(score)
  score.split(',')
end

def make_shots(scores)
  shots = []
  scores.each do |s|
    if s == 'X'
      shots << 10
      shots << 0
    else
      shots << s.to_i
    end
  end
  shots
end

def last_frame_three_throws?(scores)
  shots = make_shots(scores[0...-3])
  shots.size.even?
end

def make_frames(scores)
  if last_frame_three_throws?(scores)
    last_three_throws = scores[-3..].map do |t|
      t == 'X' ? 10 : t.to_i
    end
    make_shots(scores[0...-3]).each_slice(2).to_a << last_three_throws
  else
    make_shots(scores).each_slice(2).to_a
  end
end

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  frame[0] != 10 && frame.sum == 10
end

def make_frame_structs(frames)
  frame = Struct.new('FrameStruct', :current, :next)
  head, prev = nil

  frames.each_with_index do |f, idx|
    fr = frame.new(f, nil)
    if idx.zero?
      head = fr
    else
      prev.next = fr
    end
    prev = fr
  end

  head
end

def last_frame?(frame)
  frame.next.nil?
end

def calculate_strike_frame_point(frame)
  point = 0

  point += if last_frame?(frame.next)
             frame.current.sum + frame.next.current[0] + frame.next.current[1]
           elsif strike?(frame.next.current)
             (frame.current.sum * 2) + frame.next.next.current[0]
           else
             frame.current.sum + frame.next.current.sum
           end

  point
end

def calculate_spare_frame_point(frame)
  frame.current.sum + frame.next.current[0]
end

def calculate_all_frame_point(frames)
  point = 0
  fs = frames
  loop do
    point += if last_frame?(fs)
               fs.current.sum
             elsif strike?(fs.current)
               calculate_strike_frame_point(fs)
             elsif spare?(fs.current)
               calculate_spare_frame_point(fs)
             else
               fs.current.sum
             end

    fs = fs.next
    break if fs.nil?
  end

  point
end

score = ARGV[0]
scores = make_scores(score)
frames = make_frames(scores)
fs = make_frame_structs(frames)
puts calculate_all_frame_point(fs)
