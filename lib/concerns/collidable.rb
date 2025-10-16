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

    def self.included(base)
      if defined?(base::COLLIDABLE_MODES_EXTEND)
        self::COLLIDABLE_MODES += base::COLLIDABLE_MODES_EXTEND
      end
    end

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
        [xi, yi], # top-left corner
        [(xi + width), (yi + height)], # bottom-right corner
      ]
    end

    # IMPROVE: use native x1, x2, x3, x4
    def xy_coverage
      return static_xy_coverage if stopped? # moveable.rb

      # if moving, look ahead 1 frame
      case last_direction
      when :up
        [
          [xi, (yi - rate)], # top-left corner
          [(xi + width), (yi - rate + height)], # bottom-right corner
        ]
      when :down
        [
          [xi, (yi + rate)], # top-left corner
          [(xi + width), (yi + rate + height)], # bottom-right corner
        ]
      when :left
        [
          [(xi - rate), yi], # top-left corner
          [(xi - rate + width), (yi + height)], # bottom-right corner
        ]
      when :right
        [
          [(xi + rate), yi], # top-left corner
          [(xi + rate + width), (yi + height)], # bottom-right corner
        ]
      when :up_left
        [
          [(xi - rate), (yi - rate)], # top-left corner
          [(xi - rate + width), (yi - rate + height)], # bottom-right corner
        ]
      when :down_left
        [
          [(xi - rate), (yi + rate)], # top-left corner
          [(xi - rate + width), (yi + rate + height)], # bottom-right corner
        ]
      when :up_right
        [
          [(xi + rate), (yi - rate)], # top-left corner
          [(xi + + rate + width), (yi - rate + height)], # bottom-right corner
        ]
      when :down_right
        [
          [(xi + rate), (yi + rate)], # top-left corner
          [(xi + rate + width), (yi + rate + height)], # bottom-right corner
        ]
      else
        static_xy_coverage
      end
    end

    def collides?(other)
      self_cov = self.xy_coverage
      other_cov = other.xy_coverage

      self_x = (self_cov[0][0]..self_cov[1][0])
      self_y = (self_cov[0][1]..self_cov[1][1])

      other_x = (other_cov[0][0]..other_cov[1][0])
      other_y = (other_cov[0][1]..other_cov[1][1])

      self_x.overlap?(other_x) && self_y.overlap?(other_y)
    end

    def collide!(other)
      $logger.debug { "collide! self:#{self} other:#{other}" }
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

    private

    def xi
      x.to_i
    end

    def yi
      y.to_i
    end

    # FEATURE: Deliberate effect, like Castlevania (Simon is thrown back, actually exploitable)
    # Shouldn't be necessary to compensate for base collision behavior.
    def collision_reposition!(a, b)
      raise NotImplementedError, "collision_reposition not implemented"
    end
  end
end
