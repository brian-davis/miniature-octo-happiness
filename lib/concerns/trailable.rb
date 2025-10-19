# frozen_string_literal: true

module Simple2DDemo
  # Add trailing (tracer) functionality to an element within Game subclass.
  module Trailable
    DEFAULT_TRAIL_RATE = 2
    DEFAULT_TRAIL_LENGTH = 10

    # def self.included(base)
    # end

    class << self

      TRAILABLE_COLORS = %w(
        aqua teal green lime yellow orange fuchsia white silver
      )

    # some colors don't make good trails
      def random_trail_color
        TRAILABLE_COLORS.sample
      end
    end

    attr_accessor :trail_density, :trail_length, :initial_tick

    # IMPROVE: move more initialization options here, allow caller
    # to pass extra args options (work around named arguments)
    def initialize(**args)
      super(**args)
    end


    def trail_density
      @trail_density || DEFAULT_TRAIL_RATE
    end

    def trail_length
      @trail_length || DEFAULT_TRAIL_LENGTH
    end

    # IMPROVE: move logic here, work around initialization/attribute dependencies
    def trail!
      raise NotImplementedError, ":trail! not implemented"
    end

    # IMPROVE: move logic here, work around initialization/attribute dependencies
    def fade!
      raise NotImplementedError, ":fade! not implemented"
    end

    def fade_rate
      1.0 - (1.0 / trail_length)
    end
  end
end
