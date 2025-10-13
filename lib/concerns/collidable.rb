# frozen_string_literal: true

module Simple2DDemo
  module Collidable
    # attr_accessor :mark_collided
    # REFACTOR: use this for bounding edge detection

    def xi
      x.to_i
    end

    def yi
      y.to_i
    end

    # The window-coordinates real-estate for the object
    def static_xy_coverage
      [
        [xi, yi], # top-left corner
        [(xi + size), (yi + size)], # bottom-right corner
      ]
    end

    def xy_coverage
      return static_xy_coverage if stopped? # moveable.rb

      # if moving, look ahead 1 frame
      case last_direction
      when :up
        [
          [xi, (yi - rate)], # top-left corner
          [(xi + size), (yi - rate + size)], # bottom-right corner
        ]
      when :down
        [
          [xi, (yi + rate)], # top-left corner
          [(xi + size), (yi + rate + size)], # bottom-right corner
        ]
      when :left
        [
          [(xi - rate), yi], # top-left corner
          [(xi - rate + size), (yi + size)], # bottom-right corner
        ]
      when :right
        [
          [(xi + rate), yi], # top-left corner
          [(xi + rate + size), (yi + size)], # bottom-right corner
        ]
      when :up_left
        [
          [(xi - rate), (yi - rate)], # top-left corner
          [(xi - rate + size), (yi - rate + size)], # bottom-right corner
        ]
      when :down_left
        [
          [(xi - rate), (yi + rate)], # top-left corner
          [(xi - rate + size), (yi + rate + size)], # bottom-right corner
        ]
      when :up_right
        [
          [(xi + rate), (yi - rate)], # top-left corner
          [(xi + + rate + size), (yi - rate + size)], # bottom-right corner
        ]
      when :down_right
        [
          [(xi + rate), (yi + rate)], # top-left corner
          [(xi + rate + size), (yi + rate + size)], # bottom-right corner
        ]
      else
        static_xy_coverage
      end
    end

    def collides?(other)
      self_cov = self.xy_coverage
      other_cov = other.xy_coverage # duck-typing in blockable.rb

      self_x = (self_cov[0][0]..self_cov[1][0])
      self_y = (self_cov[0][1]..self_cov[1][1])

      other_x = (other_cov[0][0]..other_cov[1][0])
      other_y = (other_cov[0][1]..other_cov[1][1])

      self_x.overlap?(other_x) && self_y.overlap?(other_y)
    end

    def collide_stop!(other)
      self.stop!
      other.stop!
      collision_reposition!(self, other)
    end

    def collide_reflect!(other)
      collide_stop!(other)

      # swap directions
      self_dir, other_dir = other.last_direction, self.last_direction
      self.direction!(self_dir)
      other.direction!(other_dir)
    end

    private

    def collision_reposition!(a, b)
      # DEBUG: currently disabled, not necessary. Enable as necessary
      # or as a deliberate effect, like Castlevania (Simon is thrown back, actually exploitable)
      return
    end
  end
end
