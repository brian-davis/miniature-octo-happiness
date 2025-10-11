# frozen_string_literal: true

# REFACTOR: standard bundled gem structure
require_relative "../lib/concerns/steering" # Steering
require_relative "../lib/concerns/pulsing"  # Pulseable, Pulsing
require_relative "../lib/concerns/moving"   # Moveable, Moving
require_relative "../lib/concerns/bounding" # Bounding

class Ruby2D::Square
  include Pulseable
  include Moveable
  include Boundable
end

# Demonstrate basic Ruby2D operation. A single cursor object,
# a dot, with a visual pulse effect which can be moved around the window
# using directional keys, with configurable behavior at window borders.
class MovingDot < Game
  include Pulsing
  include Moving
  include Steering
  include Bounding # last position

  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)

    config_val = config["bounding_mode"].to_sym
    self.bounding_mode = config_val if config_val

    set_dot
    set_game_loop
  end

  private

  def set_dot
    x, y = window.center
    dot = Square.new(x: x, y: y)

    dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
    logger.info {"dot_size:\t#{@dot_size}"}

    cpv = config["pulse_values"]
    dot.pulse_values = if cpv.nil? || cpv.empty?
      Gradients.random_color_gradient
    else
      cpv
    end

    dot.pulse_rate = config["pulse_rate"]
    dot.color = dot.pulse_cycle.next
    self.pulse_items.push(dot)

    dot.rate = config["dot_rate"]
    dot.controlled = true

    self.moving_objects.push(dot)
  end

  def game_over?
    # config["bounding_mode"] is "eliminate"
    self.moving_objects.empty?
  end

  def end_game!
    puts "GAME OVER"
    exit
  end

  # REFACTOR: move up to Game class
  def set_game_loop
    window.update do
      self.pulsing_update_callback.call  # Pulsing
      self.moving_update_callback.call   # Moving
      self.bounding_update_callback.call # Bounding
      end_game! if game_over?
    end
  end
end