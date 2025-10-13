# frozen_string_literal: true

# Demonstrate basic Ruby2D operation. Animate many cursor objects,
# dots, each with its own visual pulse effect, movement and boundary behavior.
class MultipleMovingDots < Game
  include Pulsing

  include Moving
  include Colliding
  include Bounding # after Moving, Colliding

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
      dot = Npc.new(x: x, y: y)

      dot.size = config["dot_size"] || DEFAULT_DOT_SIZE
      logger.info {"dot_size:\t#{dot.size}"}

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

      launch_dir = Moveable.valid_directions.sample
      dot.start!(launch_dir)

      self.moving_objects.push(dot)
    end
  end

  # config["bounding_mode"] is "eliminate"
  #
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