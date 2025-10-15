# frozen_string_literal: true

# Demonstrate basic Ruby2D operation. Animate many cursor objects,
# dots, each with its own visual pulse effect, movement and boundary behavior.
class MultipleMovingDots < Simple2DDemo::Game
  include Simple2DDemo::Pulsing

  include Simple2DDemo::Moving
  # include Simple2DDemo::Colliding
  include Simple2DDemo::Bounding # after Moving, Colliding

  DEFAULT_DOTS = 2
  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)

    config_val = config["bounding_mode"]&.to_sym
    self.bounding_mode = config_val if config_val

    set_dots
    set_update
  end

  private

  def set_dots
    number_of_dots = config["number_of_dots"] || DEFAULT_DOTS

    number_of_dots.times do
      x, y = window.random_point
      dot = Simple2DDemo::Npc.new(x: x, y: y)

      dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
      logger.info {"dot_size:\t#{dot.size}"}

      cpv = config["pulse_values"]
      dot.pulse_values = if cpv.nil? || cpv.empty?
        Simple2DDemo::Gradients.random_color_gradient
      else
        cpv
      end

      dot.pulse_rate = config["pulse_rate"]
      dot.color = dot.pulse_cycle.next
      self.pulsing_objects.push(dot)

      dot.rate = config["dot_rate"]
      dot.controlled = true

      # REFACTOR
      launch_dir = Simple2DDemo::Moveable.valid_directions.sample
      dot.start!(launch_dir)

      self.moving_objects.push(dot)
    end
  end
end