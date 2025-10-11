# frozen_string_literal: true

# Add movement functionality to an element within Game subclass
# such as a Square.
module Moveable
  attr_accessor :x_movement, :y_movement, :last_direction,  :controlled, :rate

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

  # As if hitting a wall, no restart
  # DEBUG: dot hits left edge, input :left, it squishes into wall and stops, input :left again, it pushes through wall as if unbounded.
  def full_stop!
    self.last_direction = nil
    stop!
  end

  def stop!
    # self.x_movement, self.y_movement = 0, 0
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
      {
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

# Add movement functionality to a Game subclass.
# Separate concern from DirectionalInput, this handles placing
# and tracking objects across the window, not handling keyboard input.
module Moving
  def self.included(base)
    attr_accessor :moving_update_callback
    attr_reader :moving_objects
  end

  def initialize(*args)
    super(*args)

    @moving_objects = []
    @moving_update_callback = method(:move_all)
  end

  def controlled_objects
    @controlled_objects ||= moving_objects.select { |mo| mo.controlled }
  end

  def remove_object(obj)
    obj.remove and # removes from display only
    self.moving_objects.delete(obj)
  end

  private

  # Animate motion across the window.
  # Called from main loop.
  # Simple movement, including "NPC" objects.
  def move_all
    self.moving_objects.each { |obj| obj.move! }
  end
end