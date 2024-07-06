# frozen_string_literal: true

class Frame
  def initialize(shots)
    @shots = shots
  end

  def point
    @shots.sum
  end

  def strike?
    @shots[0] == 10
  end

  def spare?
    @shots[0] != 10 && point == 10
  end

  def first_shot_pins
    @shots[0]
  end

  def second_shot_pins
    @shots[1]
  end
end
