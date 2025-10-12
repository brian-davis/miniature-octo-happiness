# frozen_string_literal: true

# Add movement functionality to an element within Game subclass
# such as a Square.
#
# Movable spelling?
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

  alias_method :direction!, def start!(input_direction = nil, tag = nil)
    # puts "direction! last_direction: #{last_direction}; input_direction: #{input_direction}"

    # puts tag if tag

    new_direction = if input_direction == :toggle_start
      stopped? ? self.last_direction : :stop
    else
      input_direction
    end

    # puts new_direction

    new_x, new_y = directional_movement[new_direction]

    return unless new_x && new_y
    self.last_direction = new_direction unless new_direction == :stop
    self.x_movement, self.y_movement = new_x, new_y
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