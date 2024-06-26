# frozen_string_literal: true

class Shot
  def self.make_shot(score)
    if score == 'X'
      10
    else
      score.to_i
    end
  end
end
