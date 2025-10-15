# frozen_string_literal: true

require_relative "../helpers/gradients"

module Simple2DDemo
  # Add pulse/gradient functionality to an element within Game subclass.
  # Pulsable spelling?
  module Pulseable
    DEFAULT_PULSE_RATE = 30

    # def self.included(base)
    # end

    attr_accessor :pulse_rate, :pulse_values

    # IMPROVE: move more initialization options here, allow caller
    # to pass extra args options (work around named arguments)
    def initialize(**args)
      super(**args)
      self.pulse_values = Simple2DDemo::Gradients.black_white # default, reset after initialization IMPROVE
    end

    def pulse_cycle
      @pulse_cycle ||= self.pulse_values.gradient_cycle
    end
  end
end
