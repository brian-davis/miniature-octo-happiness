# frozen_string_literal: true

module Simple2DDemo
  module Collidable
    COLLIDABLE_MODES = [
      :reflect,
      :stop,
      :eliminate,
      :block
      # :collide_physics # FEATURE
    ]

    attr_accessor :eliminate_callback
    attr_reader :collidable_mode

    def collidable_mode=(mode)
      unless COLLIDABLE_MODES.include?(mode)
        msg = "Invalid colliding_mode #{mode}. Options are: #{COLLIDABLE_MODES.join(', ')}"
        raise ArgumentError, msg
      end
      @collidable_mode = mode
    end

    # The window-coordinates real-estate for the object
    def static_xy_coverage
      [
        [x1, y1], # top-left corner
        [x3, y3], # bottom-right corner
      ]
    end

    # The window-coordinates real-estate for the object,
    # looking ahead 1 frame and accounting for movement.
    def xy_coverage
      return static_xy_coverage if stopped? # moveable.rb

      # if moving, look ahead 1 frame
      case last_direction
      when :up
        [
          [x1, (y1 - rate)], # top-left corner
          [x3, (y3 - rate)], # bottom-right corner
        ]
      when :down
        [
          [x1, y1], # top-left corner
          [x3, (y3 + rate)], # bottom-right corner
        ]
      when :left
        [
          [(x1 - rate), y1], # top-left corner
          [(x3 - rate), y3], # bottom-right corner
        ]
      when :right
        [
          [(x1 + rate), y1], # top-left corner
          [(x3 + rate), y3], # bottom-right corner
        ]
      when :up_left
        [
          [(x1 - rate), (y1 - rate)], # top-left corner
          [(x3 - rate), (y3 - rate)], # bottom-right corner
        ]
      when :down_left
        [
          [(x1 - rate), (y1 + rate)], # top-left corner
          [(x3 - rate), (y3 + rate)], # bottom-right corner
        ]
      when :up_right
        [
          [(x1 + rate), (y1 - rate)], # top-left corner
          [(x3 + rate), (y3 - rate)], # bottom-right corner
        ]
      when :down_right
        [
          [(x1 + rate), (y1 + rate)], # top-left corner
          [(x3 + rate), (y3 + rate)], # bottom-right corner
        ]
      else
        static_xy_coverage
      end
    end

    def collides?(other)
      self_cov = self.xy_coverage   # moving
      other_cov = other.xy_coverage # static/moving
      SquarePosition.overlap?(self_cov, other_cov)
    end

    def collide!(other)
      $logger.debug { "collide! self:#{self&.xy_coverage} other:#{other&.xy_coverage}" }
      # only alter self state, not other state (it will handle that itself)
      self.send(self.collidable_mode, other)
    end

    def stop(_other)
      self.stop!
    end

    def reflect(other)
      _edge, reflection = BlockReflection.get(self, other) # /helpers
      $logger.debug { "shuttle reflect: #{_edge}, #{reflection}" }

      # IMPROVE: Moving dependency here.
      self.direction!(reflection) if reflection
    end

    def eliminate(_other)
      eliminate_callback.call(self)
    end

    # self is a Wall, do nothing, the wall doesn't move.
    # other will take care of itself
    def block(other)
      $logger.debug { "block" }
      return
    end

    #  FEATURE: pool-table logic, with assymetric force, angle, mass
    def collide_physics
      raise NotImplementedError, "collide_physics not implemented"
    end
  end
end
