# frozen_string_literal: true

# Many balls bouncing around a room, off of the walls and off of each other.
class Collisions < Simple2DDemo::Game
  include Simple2DDemo::Pulsing

  include Simple2DDemo::Moving
  include Simple2DDemo::Colliding
  include Simple2DDemo::Bounding # after Moving, Colliding

  DEFAULT_DOTS = Simple2DDemo::Moveable.valid_directions.length
  DEFAULT_DOT_SIZE = 4

  def initialize(*args)
    super(*args)
    config_val1 = config["bounding_mode"]&.to_sym
    self.bounding_mode = config_val1 if config_val1
    set_dots
  end

  private

  def set_dots
    dirs_cycle = Simple2DDemo::Moveable.valid_directions.cycle
    number_of_dots =  config["number_of_dots"] || DEFAULT_DOTS
    number_of_dots.times do
      dot_size = config["dot_size"] || DEFAULT_DOT_SIZE
      logger.info {"dot_size:\t#{dot_size}"}

      x, y = window.random_point(dot_size)
      dot = Simple2DDemo::Npc.new(x: x, y: y)
      dot.size = dot_size

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
      dot.collidable_mode = :reflect

      # from Game. IMPROVE: is there a better way to do this?
      dot.eliminate_callback = method(:remove_object)
      dot.start!(dirs_cycle.next)
      self.moving_objects.push(dot)
      self.colliding_objects.push(dot)
    end
  end
end