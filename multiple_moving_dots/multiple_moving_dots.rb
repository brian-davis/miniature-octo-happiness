# frozen_string_literal: true

# REFACTOR: standard bundled gem structure
require_relative "../lib/concerns/directional_input"
require_relative "../lib/concerns/pulse_animation"

class Ruby2D::Square
  include Pulseable
end

# Demonstrate basic Ruby2D operation. A single cursor object, a dot, with a visual pulse effect
# which can be moved around the window using directional keys, with configurable behavior at
# window borders.
class MultipleMovingDots < Game
  include DirectionalInput
  include PulseAnimation

  DEFAULT_BOUNDARY_BEHAVIOR = "pong"
  DEFAULT_DOT_RATE = 2
  DEFAULT_DOT_SIZE = 4
  DEFAULT_DOTS = 2

  # REFACTOR: break out boundary and/or collision logic into separate module(s)
  BOUNDARY_BEHAVIORS = ["pacman", "pong", "stop", "unbounded"]

  attr_reader :dots, :dot_size, :straight_rate, :diagonal_rate, :boundary_behavior
  attr_accessor :x_speed, :y_speed

  def initialize(*args)
    super(*args)

    # state machine
    @x_speed = 0
    @y_speed = 0

    set_dots
    set_motion
    set_boundary_behavior
    set_game_loop
  end

  private

  ### SET UP ###

  def set_dots
    @dots = []
    n = config["number_of_dots"] || DEFAULT_DOTS
    dot_size = config["dot_size"] || DEFAULT_DOT_SIZE # same for all
    logger.info "dot_size:\t#{self.dot_size}"
    dot_pulse_rate = config["pulse_rate"]

    n.times do
      x, y = window.random_point
      dot = Square.new(x: x, y: y)
      dot.size = dot_size
      dot.pulse_rate = dot_pulse_rate

      dot.pulse_values = GradientHelper.random_color_gradient
      dot.color = dot.color_cycle.next

      self.pulse_items.push(dot) # pulse
      self.dots.push(dot) # move!
    end
  end

  def set_motion
    # Motion u/d/l/r
    @straight_rate = config["dot_rate"] || DEFAULT_DOT_RATE
    logger.info "straight_rate:\t#{straight_rate}"

    # Motion ul/ur/dl/dr
    calc = straight_rate - (
      1 / Math.sqrt(2 * (straight_rate ** 2))
    ) # DEBUG: correct math?

    @diagonal_rate = calc
    logger.info "diagonal_rate:\t#{diagonal_rate}"
  end

  def set_boundary_behavior
    @boundary_behavior = begin
      config_val = config["boundary_behavior"] || DEFAULT_BOUNDARY_BEHAVIOR

      if BOUNDARY_BEHAVIORS.include?(config_val)
        logger.info "boundary_behavior:\t#{config_val}"
        config_val
      else
        logger.error "boundary_behavior configuration:\t \
        Bad value. Valid options: #{BOUNDARY_BEHAVIORS.join(', ')}"

        DEFAULT_BOUNDARY_BEHAVIOR
      end
    end
  end

  def set_game_loop
    window.update do
      self.pulse_update_callback.call # PulseAnimation
      move!
    end
  end


  # Animate motion of dot across the window.
  # Called from main loop.
  def move!
    # TODO
  end
end