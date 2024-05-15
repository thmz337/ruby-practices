#!/usr/bin/env ruby
# frozen_string_literal: true

Frame = Data.define(:current, :next) do
  def last_frame?
    self.next.nil?
  end

  def strike?
    current[0] == 10
  end

  def spare?
    current[0] != 10 && current.sum == 10
  end

  def calculate_strike_frame_point
    point = 0

    point += if self.next.last_frame?
               current.sum + self.next.current[0] + self.next.current[1]
             elsif self.next.strike?
               (current.sum * 2) + self.next.next.current[0]
             else
               current.sum + self.next.current.sum
             end

    point
  end

  def calculate_spare_frame_point
    current.sum + self.next.current[0]
  end
end

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

def connect_frames(frames)
  if frames[1].nil?
    Frame.new(frames[0], nil)
  else
    Frame.new(frames[0], connect_frames(frames[1..]))
  end
end

def calculate_all_frame_point(frames)
  point = 0
  fs = frames
  loop do
    point += if fs.last_frame?
               fs.current.sum
             elsif fs.strike?
               fs.calculate_strike_frame_point
             elsif fs.spare?
               fs.calculate_spare_frame_point
             else
               fs.current.sum
             end

    break if fs.last_frame?

    fs = fs.next
  end

  point
end

score = ARGV[0]
scores = make_scores(score)
frames = make_frames(scores)
first_frame = connect_frames(frames)
puts calculate_all_frame_point(first_frame)
