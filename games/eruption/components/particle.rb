# Based on Chapter 13 of book Impractical Python Projects, Lee Vaughan, No Starch Press.
# Original [Ruby port](https://github.com/brian-davis/didactic-octo-winner/blob/main/ch13/tvashtar.rb)
# Constant values adjusted for aesthetics.
# Fade-out, trails effects new.

module Simple2DDemo
  # The material ejected from a Volcano (eruption.rb)
  class Particle < Ruby2D::Square # IMPROVE: don't inherit from Square
    include Pulseable
    include Radial

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

    attr_reader :gas, :gravity
    attr_accessor :trails

    def initialize(**args)
      @gas = GASES.keys.sample
      @gravity = args.delete(:gravity)
      args[:color] = GASES[self.gas][:color]
      args[:angle] = ANGLES.sample # Radial
      args[:velocity]  = GASES[@gas][:velocity] * VELOCITY_SCALE
      args[:lr_effect] = [:left, :right].sample
      args[:ud_effect] = :up

      super(**args)

      @trails = []
    end

    def update!
      self.delta_y += self.gravity

      line = Line.new(
        x1: x,
        y1: y,
        x2: (x + delta_x),
        y2: (y + delta_y),
        width: size,
        color: color,
        opacity: color.opacity * 0.25
      )
      trails.push(line)

      self.x += delta_x
      self.y += delta_y
      self.color.opacity -= 0.025
    end

    def remove
      while (t = trails.shift)
        t.remove()
      end
      super
    end
  end
end