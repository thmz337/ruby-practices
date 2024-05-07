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
  shots.size.even? ? true : false
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
  frame_struct = Struct.new('FrameStruct', :frame, :next)
  head, prev = nil

  frames.each_with_index do |f, idx|
    f_struct = frame_struct.new(f, nil)
    if idx.zero?
      head = f_struct
    else
      prev.next = f_struct
    end
    prev = f_struct
  end

  head
end

def last_frame?(frame_struct)
  frame_struct.next.nil?
end

def calculate_strike_frame_point(f_struct)
  point = 0

  point += if last_frame?(f_struct.next)
             f_struct.frame.sum + f_struct.next.frame[0] + f_struct.next.frame[1]
           elsif strike?(f_struct.next.frame)
             (f_struct.frame.sum * 2) + f_struct.next.next.frame[0]
           else
             f_struct.frame.sum + f_struct.next.frame.sum
           end

  point
end

def calculate_spare_frame_point(f_struct)
  f_struct.frame.sum + f_struct.next.frame[0]
end

def calculate_all_frame_point(frame_structs)
  point = 0
  fs = frame_structs
  loop do
    point += if last_frame?(fs)
               fs.frame.sum
             elsif strike?(fs.frame)
               calculate_strike_frame_point(fs)
             elsif spare?(fs.frame)
               calculate_spare_frame_point(fs)
             else
               fs.frame.sum
             end

    fs = fs.next
    break if fs.nil?
  end

  point
end

score = ARGV[0]
scores = make_scores(score)
frames = make_frames(scores)
frame_structs = make_frame_structs(frames)
puts calculate_all_frame_point(frame_structs)
