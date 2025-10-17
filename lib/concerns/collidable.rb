# frozen_string_literal: true

class Array
  # a =  [
  #   [320, 240], # top_left
  #   [330, 250]  # bottom_right
  # ]
  # xr, yr = a.square_ranges
  # puts xr == (320..330) && yr == (240..250)
  def square_ranges
    x_r = self[0][0]..self[1][0]
    y_r = self[0][1]..self[1][1]
    [x_r, y_r]
  end
end

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

      self_x_range,  self_y_range  = self_cov.square_ranges
      other_x_range, other_y_range = other_cov.square_ranges

      self_x_range.overlap?(other_x_range) &&
      self_y_range.overlap?(other_y_range)
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
