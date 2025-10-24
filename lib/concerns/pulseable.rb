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

    def initialize(**args)
      pulse_arg = args.delete(:pulse_values)
      @pulse_values = pulse_arg || Simple2DDemo::Gradients.black_white
      super(**args)
    end

    def pulse_cycle
      @pulse_cycle ||= self.pulse_values.gradient_cycle
    end
  end
end
