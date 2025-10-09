# frozen_string_literal: true

require "simple-random"

# # REFACTOR: standard bundled gem structure
# require_relative "../lib/game"

require_relative "../lib/concerns/pulse_animation"
require_relative "../lib/decorators/ruby2d_decorator" # random_point

class Ruby2D::Square
  include Pulseable
end

# Produce a field of twinkling stars.
# Pulse effect simulates atmospheric distortion. Disable for outer-space view.
# Even when disabled, there is an optical illusion effect from different
# size and shade of the dots. Set very low pulse_rate value for glittery,
# Star Trek teleporter effect.
class StarField < Game
  include PulseAnimation

  MAX_DOT_SIZE = 3
  MIN_DOT_SIZE = 1
  DEFAULT_DOTS = 10

  def initialize(*args)
    super(*args)
    set_dots
  end

  private

  # populate .pulse_items (from PulseAnimation module), which will
  # be animated within the .update loop, by the .pulse! method.
  def set_dots
    n = config["number_of_dots"] || DEFAULT_DOTS

    min_dot_size = MIN_DOT_SIZE
    max_dot_size = config["dot_size"] || MAX_DOT_SIZE
    mode_dot_size = MIN_DOT_SIZE # DEBUG: this might not be useful
    logger.info "max dot size:\t#{max_dot_size}"

    rng = SimpleRandom.new

    dots_pulse_rate = config["pulse_rate"] # all the same
    logger.info "config pulse rate:\t#{dots_pulse_rate}"

    dots_pulse_values = config["pulse_values"]
    logger.info "config pulse values:\t#{dots_pulse_values}"

    n.times do
      dot_size = rng.triangular(min_dot_size, mode_dot_size, max_dot_size).round
      x, y = window.random_point
      dot = Ruby2D::Square.new(
        x: x,
        y: y,
        size: dot_size
      )

      dot.pulse_rate = dots_pulse_rate

      # give each dot a unique subset of the pulse values
      dot.pulse_values = dots_pulse_values # uses default
      pulse_values_length = rand(dot.pulse_values.length)
      pulse_values_offset = rand(dot.pulse_values.length - pulse_values_length)
      pulse_values_end    = pulse_values_offset + pulse_values_length
      dot.pulse_values = dot.pulse_values[pulse_values_offset..pulse_values_end]

      rand(10).times { dot.color_cycle.next }
      dot.color = dot.color_cycle.next

      pulse_items.push(dot)
    end
  end
end