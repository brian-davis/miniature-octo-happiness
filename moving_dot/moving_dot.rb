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
class MovingDot < Game
  include DirectionalInput
  include PulseAnimation

  DEFAULT_BOUNDARY_BEHAVIOR = "pong"
  DEFAULT_DOT_RATE = 2
  DEFAULT_DOT_SIZE = 4

  # REFACTOR: break out boundary and/or collision logic into separate module(s)
  BOUNDARY_BEHAVIORS = ["pacman", "pong", "stop", "unbounded"]

  attr_reader :dot, :dot_size, :straight_rate, :diagonal_rate, :boundary_behavior
  attr_accessor :x_speed, :y_speed

  def initialize(*args)
    super(*args)

    # state machine
    @x_speed = 0
    @y_speed = 0

    set_dot
    set_motion
    set_boundary_behavior

    set_inputs
    set_game_loop
  end

  private

  ### SET UP ###

  def set_dot
    x, y = window.center
    @dot = Square.new(x: x, y: y)
    @dot_size = @dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
    logger.info "dot_size:\t#{self.dot_size}"

    dot.pulse_values = config["pulse_values"] # Pulsable
    dot.pulse_rate = config["pulse_rate"]
    dot.color = dot.color_cycle.next

    self.pulse_items.push(dot)
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

  def set_inputs
    window.on :key_down do |event|
      logger.debug event
      case event.key
      when "space", "keypad 5", "k"
        toggle_stop_start
      end
    end
  end

  ### STATE MACHINE ###

  def stopped?
    x_speed == 0 && y_speed == 0
  end

  def moving?
    !stopped?
  end

  def speed!(x, y)
    logger.debug "speed!(#{x},#{y})"
    self.x_speed, self.y_speed = x, y
  end

  # REFACTOR: don't duplicate behavior between motion and boundary concerns.
  # :stop is a sticky wall. Can't slide along the edge.
  # That's friction!
  def stop!
    logger.debug "stop!"
    speed!(0, 0)
  end

  def start!
    logger.debug "start!"
    direction!
  end

  def toggle_stop_start
    logger.debug "toggle_stop_start"
    moving? ? stop! : start!
  end

  def left!
    speed!(-straight_rate, 0)
  end

  def right!
    speed!(straight_rate, 0)
  end

  def up!
    speed!(0, -straight_rate)
  end

  def down!
    speed!(0, straight_rate)
  end

  def up_left!
    speed!(-diagonal_rate, -diagonal_rate)
  end

  def up_right!
    speed!(diagonal_rate, -diagonal_rate)
  end

  def down_left!
    speed!(-diagonal_rate, diagonal_rate)
  end

  def down_right!
    speed!(diagonal_rate, diagonal_rate)
  end

  def top_edge?
    dot.y <= dot_size
  end

  def right_edge?
    dot.x >= (window_width - dot_size)
  end

  def bottom_edge?
    dot.y >= (window_height - dot_size)
  end

  def left_edge?
    dot.x <= dot_size
  end

  def out_of_bounds?
    top_edge? || right_edge? || bottom_edge? || left_edge?
  end

  # :pacman will produce virtual-globe behavior.
  # Hit the wall going left, now emerge from the right, still moving left.
  def pacman!
    logger.debug "pacman!"
    if left_edge?
      self.dot.x = window_width - dot_size
    elsif right_edge?
      self.dot.x = dot_size
    elsif top_edge?
      self.dot.y = window_height - dot_size
    elsif bottom_edge?
      self.dot.y = dot_size
    end
  end

  # :pong will produce bouncing behavior.
  # Hit the wall going left, now you are going right.
  def pong!
    logger.debug "pong!"
    stop!
    new_motion = case last_directional_input
    when :left
      :right
    when :right
      :left
    when :up
      :down
    when :down
      :up
    when :up_left
      if left_edge?
        :up_right
      elsif top_edge?
        :down_left
      end
    when :up_right
      if right_edge?
        :up_left
      elsif top_edge?
        :down_right
      end
    when :down_left
      if left_edge?
        :down_right
      elsif bottom_edge?
        :up_left
      end
    when :down_right
      if right_edge?
        :down_left
      elsif bottom_edge?
        :up_right
      end
    end
    last_directional_input = new_motion
    start!
  end

  # :unbounded lets you go as far as you want off-screen,
  # no indication how to get back. Not recommended.
  def unbounded!
    logger.debug "unbounded!"
    # do nothing
  end

  # Animate motion of dot across the window.
  # Called from main loop.
  def move!
    self.dot.x += x_speed
    self.dot.y += y_speed
    send("#{boundary_behavior}!") if out_of_bounds?
  end
end