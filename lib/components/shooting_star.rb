module Simple2DDemo
  # Animated Moving object in Game window.
  # Draws a line or shape by printing multiple dots in succession

  class ShootingStarTrail < Ruby2D::Square # IMPROVE: don't inherit from Square
    attr_accessor :fade_rate

    def initialize(**args)
      @fade_rate = args.delete(:fade_rate)
      super(**args)
    end

    def fade!
      self.color.opacity -= self.fade_rate
    end
  end

  class ShootingStar < Ruby2D::Square # IMPROVE: don't inherit from Square
    include Pulseable
    include Moveable

    # FIX: Bounding/Collidable dependency inversion.
    # Shouldn't need to include this if Game is set to unbounded/wrap/eliminate
    # Just use walls for actual bounding behavior.
    include Collidable

    include Trailable

    FADE_RATE_ADJUSTMENT = 250.0

    def initialize(**args)
      super(**args)
    end

    def trail_fade_rate
      # DEBUG: adjustment is a magic number found by trial-and-error,
      #   :opacity values more sensitive than expected
      @trail_fade_rate ||= (self.trail_length / FADE_RATE_ADJUSTMENT)
    end

    def trail!
      # Duplicate self at present cycle. Don't add to moving_objects.
      # .new prints in window (magic)
      trailed = Simple2DDemo::ShootingStarTrail.new(
        x:     self.x,
        y:     self.y,
        size:  self.size,
        color: self.color,
        fade_rate: self.trail_fade_rate
      )

      # $logger.debug {
      #   "trailed x: #{trailed.x}; y: #{trailed.y}; size: #{trailed.size}; color: #{trailed.color}"
      # }

      # :trail_all will register this in :trailed_objects
      trailed
    end
  end
end