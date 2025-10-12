# frozen_string_literal: true

# Add movement functionality to an element within Game subclass
# such as a Square.
module Moveable
  attr_accessor :x_movement, :y_movement, :last_direction,  :controlled, :rate

  # FEATURE REQUEST: Develop alternate system based on radial heading degrees.
  VALID_DIRECTIONS = [
    :left, :right, :up, :down,
    :up_left, :up_right, :down_left, :down_right,
    :stop
  ]
  def self.valid_directions(include_stop = false)
    if include_stop
      VALID_DIRECTIONS
    else
      VALID_DIRECTIONS - [:stop]
    end
  end

  def initialize(**args)
    super(**args)

    @x_movement = 0
    @y_movement = 0
  end

  def diagonal_rate
    # float values OK
    @diagonal_rate ||= (rate - (1 / Math.sqrt(2 * (rate ** 2))))
  end

  # update position in window, called from game-loop
  def move!
    self.x += x_movement
    self.y += y_movement
  end

  def stopped?
    x_movement == 0 && y_movement == 0
  end

  def moving?
    !stopped?
  end

  def stop!
    direction!(:stop)
  end

  alias_method :direction!, def start!(input_direction = nil)
    new_direction = if input_direction == :toggle_start
      stopped? ? self.last_direction : :stop
    else
      input_direction
    end
    x, y = directional_movement[new_direction]
    return unless x && y
    self.last_direction = new_direction unless new_direction == :stop
    self.x_movement, self.y_movement = x, y
  end

  private

  def directional_movement
    @directional_movement ||= begin
      raise ArgumentError, "rate has not been set" unless rate
      direction_key = {
        left:       [-rate, 0],
        right:      [rate,  0],
        up:         [0,              -rate],
        down:       [0,              rate],

        up_left:    [-diagonal_rate, -diagonal_rate],
        up_right:   [diagonal_rate,  -diagonal_rate],
        down_left:  [-diagonal_rate, diagonal_rate],
        down_right: [diagonal_rate,  diagonal_rate],

        stop:       [0,              0]
      }
    end
  end
end