# frozen_string_literal: true

# Demonstrate basic Ruby2D operation. A single cursor object,
# a dot, with a visual pulse effect which can be moved around the window
# using directional keys, with configurable behavior at window borders.
# A wall object in in the middle of the map, blocking some movements.
class Obstacle < Game
  include Pulsing
  include Steering

  include Moving
  include Colliding

  include Bounding # after Moving, Colliding
  include Blocking

  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)

    config_val = config["bounding_mode"]&.to_sym
    self.bounding_mode = config_val if config_val

    set_dot
    set_obstacle
    set_update
  end

  private

  def set_dot
    x, y = window.center
    @dot = Pc.new(x: x, y: y)

    @dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
    logger.info {"dot_size:\t#{@dot.size}"}

    cpv = config["pulse_values"]
    @dot.pulse_values = if cpv.nil? || cpv.empty?
      Gradients.random_color_gradient
    else
      cpv
    end

    @dot.pulse_rate = config["pulse_rate"]
    @dot.color = @dot.pulse_cycle.next
    self.pulse_items.push(@dot)

    @dot.rate = config["dot_rate"]
    @dot.controlled = true

    self.moving_objects.push(@dot)
  end

  def set_obstacle
    @wall = Wall.new(
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
      Gradients.random_color_gradient
    else
      cpv
    end

    @wall.color = @dot.pulse_cycle.next


    self.pulse_items.push(@wall)

    @wall.blocking_mode = :block_reflect
    self.blocks.push(@wall)
  end

  # If config["bounding_mode"] is "eliminate"
  def game_over?
    self.moving_objects.empty?
  end

  def end_game!
    puts "GAME OVER"
    exit
  end

  # REFACTOR: move up to Game superclass?
  def set_update
    window.update do
      self.pulsing_update.call  # Pulsing
      self.bounding_update.call # before moving
      self.blocking_update.call # before moving
      self.moving_update.call
      end_game! if game_over?
    end
  end
end