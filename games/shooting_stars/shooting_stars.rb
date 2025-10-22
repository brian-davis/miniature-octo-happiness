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

  attr_reader :dot_size, :dot_rate, :number_of_dots,
              :trail_length, :trail_interval

  def initialize(*args)
    super(*args)
    self.bounding_mode = config["bounding_mode"]&.to_sym

    @number_of_dots = config["number_of_dots"] || DEFAULT_DOTS

    # all the same
    @dot_size       = config["dot_size"] || DEFAULT_DOT_SIZE
    @dot_rate       = config["dot_rate"]

    @trail_length   = config["trail_length"]
    @trail_interval = config["trail_interval"]

    logger.info {"bounding_mode:\t#{bounding_mode}"}

    logger.info {"number_of_dots:\t#{number_of_dots}"}

    logger.info {"dot_size:\t#{dot_size}"}
    logger.info {"dot_rate:\t#{dot_rate}"}

    logger.info {"trail_length:\t#{trail_length}"}
    logger.info {"trail_interval:\t#{trail_interval}"}


    set_dots
  end

  private

  def set_dots
    number_of_dots.times do
      x, y = window.random_point
      dot = Simple2DDemo::ShootingStar.new(
        x: x,
        y: y,
        size: dot_size,
        enable_trail: self.enable_trail,
        meter: self.method(:meter?),
        rate: dot_rate,
        trail_length: trail_length,
        trail_interval: trail_interval
      )

      launch_dir = Simple2DDemo::Moveable.valid_directions.sample
      dot.start!(launch_dir)

      self.moving_objects.push(dot)
    end
  end
end