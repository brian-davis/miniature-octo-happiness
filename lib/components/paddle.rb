# Control the Pong game. Only moves up or down.
# Collision behavior is similar to Wall.
# IMPROVE: Don't inherit from Rectangle.
module Simple2DDemo
  class Paddle < Ruby2D::Rectangle
    include Pulseable
    include Moveable

    prepend Collidable
    COLLIDABLE_MODES.push(:pong_paddle) # must be `prepend`

    attr_accessor :player_number

    def initialize(**args)
      super(**args)
      self.collidable_mode = :pong_paddle
    end

    # Override Movable (must be `include`)
    def x_movement
      0
    end

    def pong_paddle(other)
      $logger.debug { "pong_paddle self: #{self}, other: #{other}"}
      if self.moving? && other.collidable_mode == :block
        reflect(other)
      else
        block(other)
      end
    end
  end
end