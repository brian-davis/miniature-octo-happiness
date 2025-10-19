# frozen_string_literal: true

# Animate drawing a line or shape by printing multiple dots in succession.
# ShootingStars
class Tracers < Simple2DDemo::Game
  # include Simple2DDemo::Pulsing
  include Simple2DDemo::Moving
  include Simple2DDemo::Bounding # after Moving, Colliding
  include Simple2DDemo::Trailing

  DEFAULT_DOTS = 2
  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)
    self.bounding_mode = config["bounding_mode"]&.to_sym
    set_dots
  end

  private

  def set_dots
    number_of_dots = config["number_of_dots"] || DEFAULT_DOTS

    # all the same
    trail_density = config["trail_density"]
    logger.info { "trail_density:\t#{trail_density}" }
    trail_length = config["trail_length"]
    logger.info { "trail_length:\t#{trail_length}" }

    number_of_dots.times do
      x, y = window.random_point
      dot = Simple2DDemo::ShootingStar.new(x: x, y: y)
      dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
      logger.info {"dot.size:\t#{dot.size}"}

      dot.color = Simple2DDemo::Trailable.random_trail_color

      dot.rate = config["dot_rate"]
      logger.info {"dot.rate:\t#{dot.rate}"}

      launch_dir = Simple2DDemo::Moveable.valid_directions.sample
      dot.start!(launch_dir)

      self.moving_objects.push(dot)
      dot.trail_density = trail_density
      dot.trail_length = trail_length

      self.trailing_objects.push(dot)
    end
  end
end