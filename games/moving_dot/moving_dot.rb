# frozen_string_literal: true

# Demonstrate basic Ruby2D operation. A single cursor object,
# a dot, with a visual pulse effect which can be moved around the window
# using directional keys, with configurable behavior at window borders.
class MovingDot < Simple2DDemo::Game
  include Simple2DDemo::Pulsing
  include Simple2DDemo::Steering

  include Simple2DDemo::Moving
  include Simple2DDemo::Colliding
  include Simple2DDemo::Bounding # after Moving, Colliding

  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)

    config_val = config["bounding_mode"]&.to_sym
    self.bounding_mode = config_val if config_val

    set_dot
    set_update
  end

  private

  def set_dot
    x, y = window.center
    dot = Simple2DDemo::Pc.new(x: x, y: y)

    dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
    logger.info {"dot_size:\t#{@dot_size}"}

    cpv = config["pulse_values"]
    dot.pulse_values = if cpv.nil? || cpv.empty?
      Simple2DDemo::Gradients.random_color_gradient
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

  # config["bounding_mode"] is "eliminate"x
  def game_over?
    self.moving_objects.empty?
  end

  def end_game!
    puts "GAME OVER"
    exit
  end

  # REFACTOR: move up to Game class
  def set_update
    window.update do
      self.pulsing_update.call  # Pulsing
      self.bounding_update.call # before moving
      self.moving_update.call
      end_game! if game_over?
    end
  end
end