module Simple2DDemo
  # Element of a radiant meteor shower.
  class Meteor < Ruby2D::Square # IMPROVE: don't inherit from Square
    include Radial

    ANGLES    = (0..90)
    MAX_TRAIL = 20
    OPACITY_ADJUSTMENT = 0.025

    attr_accessor :trails, :randomize, :fuzz_origin, :updates

    def initialize(**args)
      # IMPROVE: use Trailable
      @trails = []
      @updates = 0

      @randomize = args.delete(:randomize)
      @fuzz_origin = args.delete(:fuzz_origin)

      if randomize
        args[:angle]     = rand(ANGLES)
        args[:lr_effect] = [:left, :right].sample
        args[:ud_effect] = [:up, :down].sample
      end

      super(**args)
    end

    def update!
      if trails.length < MAX_TRAIL
        line = Line.new(
          x1:      x,
          y1:      y,
          x2:      (x + delta_x),
          y2:      (y + delta_y),
          width:   size,
          color:   color,
          opacity: color.opacity * 0.25
        )
        trails.push(line)
      end

      self.x += delta_x
      self.y += delta_y

      self.color.opacity -= OPACITY_ADJUSTMENT

      self.updates += 1
    end

    def remove
      while (t = trails.shift)
        t.remove()
      end
      super
    end
  end
end