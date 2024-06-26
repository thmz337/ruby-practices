# frozen_string_literal: true

class Game
  attr_reader :points

  def initialize(frames)
    @frames = frames
    @current_frame_index = 0
    @points = calc_points
  end

  private

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
