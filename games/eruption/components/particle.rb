# Based on Chapter 13 of book Impractical Python Projects, Lee Vaughan, No Starch Press.
# Original [Ruby port](https://github.com/brian-davis/didactic-octo-winner/blob/main/ch13/tvashtar.rb)
# Constant values adjusted for aesthetics.
# Fade-out, trails effects new.

module Simple2DDemo
  # The material ejected from a Volcano (eruption.rb)
  class Particle < Ruby2D::Square # IMPROVE: don't inherit from Square
    include Pulseable
    include Moveable

    GASES = {
      'CO2' => {
        color: "yellow",
        velocity: 2
      },
      'H2O' => {
        color: "red",
        velocity: 3
      },
      'H2S' => {
        color: "orange",
        velocity: 2.5
      },
      'SO2' => {
        color: "white",
        velocity: 1.5
      }
    }

    ANGLES = [88, 85, 80, 78, 75, 68, 65, 55, 45]
    VELOCITY_SCALE = 3.3

    attr_reader :gas, :velocity, :gravity
    attr_accessor :delta_x, :delta_y, :trails

    def initialize(**args)
      @gas = GASES.keys.sample
      $logger.debug { "@gas: #{@gas}" }
      @gravity = args.delete(:gravity)
      args[:color] = GASES[self.gas][:color]
      super(**args)
      $logger.debug { "self.color: #{self.color}" }
      @velocity  = GASES[self.gas][:velocity] * VELOCITY_SCALE
      $logger.debug { "@velocity: #{@velocity}" }

      radians = Math.radians(ANGLES.sample) # /decorators

      @delta_x = self.velocity * Math.cos(radians) * [-1, 1].sample # random left/right
      @delta_y = -self.velocity * Math.sin(radians) # negative is up

      # Each moving object keeps its own trails, not tracked at the game level,
      # cleans up after itself with :remove patch below
      # REFACTOR: use this pattern instead of Trailing concern,
      # or re-do that module to use this pattern.
      @trails = []
    end

    # Per-frame movement. called from game loop
    def update!
      self.delta_y += self.gravity # positive is down

      line = Line.new(
        x1: self.x,                  y1: self.y,
        x2: (self.x + self.delta_x), y2: (self.y + self.delta_y),
        width: self.size,
        color: self.color,
        opacity: self.color.opacity * 0.25
      )
      trails.push(line)

      self.x += self.delta_x
      self.y += self.delta_y

      self.color.opacity -= 0.025
    end

    # patch Ruby2D:Square
    def remove
      while (t = trails.shift)
        t.remove()
      end
      super
    end
  end
end