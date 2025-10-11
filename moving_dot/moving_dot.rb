# frozen_string_literal: true

# REFACTOR: standard bundled gem structure
require_relative "../lib/concerns/steering" # Steering
require_relative "../lib/concerns/pulsing"  # Pulseable, Pulsing
require_relative "../lib/concerns/moving"   # Moveable, Moving

class Ruby2D::Square
  include Pulseable
  include Moveable
end

# Demonstrate basic Ruby2D operation. A single cursor object,
# a dot, with a visual pulse effect which can be moved around the window
# using directional keys, with configurable behavior at window borders.
class MovingDot < Game
  include Pulsing
  include Moving
  include Steering

  DEFAULT_DOT_SIZE = 4

  # REFACTOR: break out boundary and/or collision logic into separate module(s)
  DEFAULT_BOUNDARY_BEHAVIOR = "pong"
  BOUNDARY_BEHAVIORS = ["pacman", "pong", "stop", "unbounded"]
  attr_reader :boundary_behavior

  def initialize(*args)
    super(*args)

    set_dot
    set_boundary_behavior
    set_game_loop
  end

  private

  ### SET UP ###

  def set_dot
    x, y = window.center
    dot = Square.new(x: x, y: y)

    # REFACTOR: break out boundary and/or collision logic into separate module(s)
    @dot_size = dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
    logger.info "dot_size:\t#{@dot_size}"

    dot.pulse_values = config["pulse_values"] # Pulsable
    dot.pulse_rate = config["pulse_rate"]
    dot.color = dot.color_cycle.next
    self.pulse_items.push(dot)

    dot.rate = config["dot_rate"]
    dot.controlled = true

    self.moving_objects.push(dot)
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
      self.pulse_update_callback.call # Pulsing
      move!
    end
  end

  ### STATE MACHINE ###

  # Animate motion across the window.
  # Called from main loop.
  # Simple movement, including "NPC" objects.
  def move!
    self.moving_objects.each { |obj| obj.move! }
    # send("#{boundary_behavior}!") if out_of_bounds?
  end

  # From Steering input channel, "PC" objects receive direction from player.
  def direction!
    self.controlled_objects.each do |obj|
      obj.direction!(self.last_steering_input)
    end
  end

  # def top_edge?
  #   dot.y <= dot_size
  # end

  # def right_edge?
  #   dot.x >= (window_width - dot_size)
  # end

  # def bottom_edge?
  #   dot.y >= (window_height - dot_size)
  # end

  # def left_edge?
  #   dot.x <= dot_size
  # end

  # def out_of_bounds?
  #   top_edge? || right_edge? || bottom_edge? || left_edge?
  # end

  # # :pacman will produce virtual-globe behavior.
  # # Hit the wall going left, now emerge from the right, still moving left.
  # def pacman!
  #   logger.debug "pacman!"
  #   if left_edge?
  #     self.dot.x = window_width - dot_size
  #   elsif right_edge?
  #     self.dot.x = dot_size
  #   elsif top_edge?
  #     self.dot.y = window_height - dot_size
  #   elsif bottom_edge?
  #     self.dot.y = dot_size
  #   end
  # end

  # # :pong will produce bouncing behavior.
  # # Hit the wall going left, now you are going right.
  # def pong!
  #   logger.debug "pong!"
  #   stop!
  #   new_motion = case last_directional_input
  #   when :left
  #     :right
  #   when :right
  #     :left
  #   when :up
  #     :down
  #   when :down
  #     :up
  #   when :up_left
  #     if left_edge?
  #       :up_right
  #     elsif top_edge?
  #       :down_left
  #     end
  #   when :up_right
  #     if right_edge?
  #       :up_left
  #     elsif top_edge?
  #       :down_right
  #     end
  #   when :down_left
  #     if left_edge?
  #       :down_right
  #     elsif bottom_edge?
  #       :up_left
  #     end
  #   when :down_right
  #     if right_edge?
  #       :down_left
  #     elsif bottom_edge?
  #       :up_right
  #     end
  #   end
  #   last_directional_input = new_motion
  #   start!
  # end

  # # :unbounded lets you go as far as you want off-screen,
  # # no indication how to get back. Not recommended.
  # def unbounded!
  #   logger.debug "unbounded!"
  #   # do nothing
  # end
end