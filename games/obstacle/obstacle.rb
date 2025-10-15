# frozen_string_literal: true

# Demonstrate basic Ruby2D operation. A single cursor object,
# a dot, with a visual pulse effect which can be moved around the window
# using directional keys, with configurable behavior at window borders.
# A wall object in in the middle of the map, blocking some movements.
class Obstacle < Simple2DDemo::Game
  include Simple2DDemo::Pulsing
  include Simple2DDemo::Moving
  include Simple2DDemo::Steering
  include Simple2DDemo::Colliding
  include Simple2DDemo::Bounding
  # include Simple2DDemo::Blocking # REFACTOR

  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)

    config_val = config["bounding_mode"]&.to_sym
    self.bounding_mode = config_val if config_val

    set_dot
    set_obstacle
  end

  private

  def set_dot
    x, y = window.center
    @dot = Simple2DDemo::Pc.new(x: x, y: y)

    @dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
    logger.info {"dot_size:\t#{@dot.size}"}

    cpv = config["pulse_values"]
    @dot.pulse_values = if cpv.nil? || cpv.empty?
      Simple2DDemo::Gradients.random_color_gradient
    else
      cpv
    end

    @dot.pulse_rate = config["pulse_rate"]
    @dot.color = @dot.pulse_cycle.next
    self.pulsing_objects.push(@dot)

    @dot.rate = config["dot_rate"]
    @dot.controlled = true

    @dot.collidable_mode = :reflect
    self.game_enders.push(@dot)

    self.moving_objects.push(@dot)
    self.colliding_objects.push(@dot)
  end

  def set_obstacle
    @wall = Simple2DDemo::Wall.new(
      x: @dot.x - 100,
      y: @dot.y - @dot.width,

      width: @dot.width + 10,
      height: 100,

      color: 'teal',
      z: @dot.z
    )
    @wall.pulse_rate = config["pulse_rate"]

    cpv = config["pulse_values"]
    @wall.pulse_values = if cpv.nil? || cpv.empty?
      Simple2DDemo::Gradients.random_color_gradient
    else
      cpv
    end

    @wall.color = @dot.pulse_cycle.next
    self.pulsing_objects.push(@wall)

    @wall.collidable_mode = :block

    self.colliding_objects.push(@wall)
  end
end