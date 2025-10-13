# frozen_string_literal: true

require_relative "../helpers/gradients"

module Simple2DDemo
  # Add pulse/gradient functionality to an element within Game subclass.
  # Re-open and include as necessary. example (from star_field.rb):
  # class Ruby2D::Square
  #   include Pulseable
  # end
  #
  # Pulsable spelling?
  module Pulseable
    DEFAULT_PULSE_RATE = 30

    # Include into game element, e.g. Ruby2D::Square
    # Give individual elements their own pulse behaviors.
    def self.included(base)
      attr_accessor :pulse_rate, :pulse_values
    end

    def initialize(**args)
      super(**args)
      self.pulse_values = Gradients.black_white # default, reset after initialization
    end

    def pulse_cycle
      @pulse_cycle ||= self.pulse_values.gradient_cycle
    end
  end
end
