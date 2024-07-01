# frozen_string_literal: true

class Game
  attr_reader :points

  def initialize(scores)
    @scores = scores
    @frames = make_frames
    @current_frame_index = 0
    @points = calc_points
  end

  private

  def make_shots(scores)
    shots = []
    scores.each do |score|
      shots << Shot.make_shot(score)
      shots << 0 if score == 'X'
    end
    shots
  end

  def make_frames
    if last_frame_three_throws?
      last_three_throws = @scores[-3..].map do |s|
        s == 'X' ? 10 : s.to_i
      end
      shot_pairs = make_shots(@scores[0...-3]).each_slice(2).to_a << last_three_throws
    else
      shot_pairs = make_shots(@scores).each_slice(2).to_a
    end

    shot_pairs.map do |shot_pair|
      Frame.new(shot_pair)
    end
  end

  def next_frame
    @frames[@current_frame_index + 1]
  end

  def second_next_frame
    @frames[@current_frame_index + 2]
  end

  def forward_current_frame!
    @current_frame_index += 1
  end

  def last_frame?
    next_frame.nil?
  end

  def last_frame_three_throws?
    make_shots(@scores[0...-3]).size.even?
  end

  def calc_points
    game_points = 0
    @frames.each do |frame|
      return game_points += frame.point if last_frame?

      game_points += frame.point

      game_points += next_frame.first_shot_pins if frame.spare?

      if frame.strike?
        game_points += if next_frame.strike?
                         second_next_frame ? 10 + second_next_frame.first_shot_pins : 10 + next_frame.second_shot_pins
                       else
                         next_frame.first_shot_pins + next_frame.second_shot_pins
                       end
      end

      forward_current_frame!
    end
    game_points
  end
end
