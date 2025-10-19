module Simple2DDemo
  # Animated Moving object in Game window.
  # Draws a line or shape by printing multiple dots in succession

  class ShootingStar < Ruby2D::Square # IMPROVE: don't inherit from Square
    include Pulseable
    include Moveable
    include Collidable # IMPROVE: Bounding/Collidable dependency inversion
    include Trailable

    def initialize(**args)
      @type = args.delete(:type)
      super(**args)
    end

    def trail!(master_tick)
      # Duplicate self at present cycle. Don't add to moving_objects.
      # .new prints in window (magic)
      trailed = Simple2DDemo::ShootingStar.new(x: x, y: y, size: size, color: color)
      trailed.trail_density = self.trail_density # used for fade!
      trailed.trail_length = self.trail_length # used for :trail_all remove()
      trailed.trail_length = self.trail_length # used for :trail_all remove()
      trailed.initial_tick = master_tick

      $logger.debug {
        "trailed x: #{trailed.x}; y: #{trailed.y}; size: #{trailed.size}; color: #{trailed.color}"
      }

      # :trail_all will register this in :trailed_objects
      trailed
    end

    # called on member of :trailed_objects
    def fade!
      self.color.opacity *= fade_rate
    end
  end
end