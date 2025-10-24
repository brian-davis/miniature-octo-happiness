# frozen_string_literal: true

module Simple2DDemo
  # Add trailing (tracer) functionality to an element within Game subclass.
  # REFACTOR; DRY, consolidate with line-based solution in Eruption, Radiant
  module Trailable
    TRAIL_MAX_LENGTH = 10
    TRAIL_INTERVAL = 10

    def self.included(base)
      unless base.ancestors.map(&:name).include?("Simple2DDemo::Moveable")
        raise ArgumentError, "Trailable depends on Moveable"
      end
    end

    # some colors don't make good trails
    TRAILABLE_COLORS = %w(aqua teal green lime yellow orange fuchsia white silver)

    attr_reader :meter, :enable_trail
    attr_accessor :trail_objects, :trail_length, :trail_interval

    def initialize(**args)
      args[:color] ||= TRAILABLE_COLORS.sample
      @meter         = args.delete(:meter)
      @enable_trail  = !!args.delete(:enable_trail)

      @trail_length   = args.delete(:trail_length) || TRAIL_MAX_LENGTH
      @trail_interval = args.delete(:trail_interval) || TRAIL_INTERVAL

      super(**args)

      @trail_objects = []
    end

    # decorate Moveable
    def move!
      trail_cycle
      super
    end

    def trail_cycle
      return unless enable_trail
      fade_all
      trail_head
      dissipate
    end

    def fade_all
      # first trailer is closest to actual comet, brightest
      trail_objects.reverse_each do |trailed_object|
        trailed_object.fade! # duck-type
      end
    end

    def trail_head
      if meter.call(self.trail_interval)
        trailed = trail!
        trail_objects.unshift(trailed) # new 1st is unfaded
      end
    end

    # like Game:remove_object
    def dissipate
      raise "trail_objects overflow" if trail_objects.length > self.trail_length
      final_trail = trail_objects[self.trail_length - 1]
      return if final_trail.nil?

      final_trail.remove and # removes from display only
      trail_objects.delete(final_trail) and
      $logger.debug { "dissipate: #{final_trail}" }
    end

    def trail!
      # Duplication logic will be specific to implementing class
      # Trail objects should implement :initial_tick, :fade!, :faded? methods
      raise NotImplementedError, ":trail! not implemented"
    end
  end
end
