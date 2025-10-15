# Control the Pong game. Only moves up or down.
# Collission behavior is similar to Wall.
# IMPROVE: Don't inherit from Rectangle.
module Simple2DDemo
  class Paddle < Ruby2D::Rectangle
    COLLIDABLE_MODES = [:pong_paddle]

    include Pulseable
    include Moveable
    include Collidable

    attr_accessor :player_number

    def initialize(**args)
      super(**args)
      self.collidable_mode = :pong_paddle
    end

    # Override Movable
    def x_movement
      0
    end

    def pong_paddle(other)
      $logger.debug { "pong_paddle self: #{self}, other: #{other}"}
      if self.moving? && other.collidable_mode == :block
        # self.moving? && other.is_a?(Simple2DDemo::Wall)
        reflect(other)
      else
        block(other)
      end
    end
  end
end