# frozen_string_literal: true

module Simple2DDemo
  # Add movement based on degree-based radial angles.
  # Alternative to Moveable
  module Radial
    # def self.included(base)
    # end

    LR_ADJUST = { left: -1, right: 1}
    UD_ADJUST = { up: -1, down: 1}

    attr_reader :angle, :velocity, :lr_effect, :ud_effect
    attr_accessor :delta_x, :delta_y # continually adjustable

    def initialize(**args)
      @angle = args.delete(:angle)
      raise ArgumentError, ":angle is required" unless @angle

      @velocity = args.delete(:velocity)
      raise ArgumentError, ":velocity is required" unless @velocity

      @lr_effect = args.delete(:lr_effect)
      raise ArgumentError, ":lr_effect is required" unless @lr_effect

      @ud_effect = args.delete(:ud_effect)
      raise ArgumentError, ":ud_effect is required" unless @ud_effect

      super(**args)

      self.delta_x = xrad() # Radial
      self.delta_y = yrad() # Radial
    end

    private

    def xrad
      self.velocity * Math.cos(radians) * LR_ADJUST[lr_effect]
    end

    def yrad
      self.velocity * Math.sin(radians) * UD_ADJUST[ud_effect]
    end

    def radians
      Math.radians(self.angle) # /decorators
    end
  end
end
