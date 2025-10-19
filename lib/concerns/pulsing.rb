# frozen_string_literal: true

require_relative "../helpers/gradients"

module Simple2DDemo
  # Add pulse/gradient functionality to a Game subclass.
  module Pulsing
    # include into Game subclass (with .window object)

    def self.included(base)
      unless base.ancestors.map(&:name).include?("Simple2DDemo::Game")
        raise ArgumentError, "Pulsing depends on Game"
      end
    end

    attr_reader :enable_pulse, :pulsing_update
    attr_accessor :pulsing_objects
    def initialize(*args)
      # if base is e.g. StarField < Game, then:
      # Game -> this -> StarField
      super(*args)
      self.update_actions.push(:pulse_all)

      @enable_pulse = config["enable_pulse"] # Game
      logger.info {"config enable pulse: #{@enable_pulse}"}
      @pulsing_objects = []
      remove_observables.push(:pulsing_objects)
    end

    private

    def pulse_all
      return unless enable_pulse
      pulsing_objects.each do |pulsing_object|
        # :master_tick Game dependency
        if master_tick % pulsing_object.pulse_rate == 0
          # e.g. Square, with .color method FEATURE: expand, make configurable
          pulsing_object.color = pulsing_object.pulse_cycle.next
        end
      end
    end
  end
end
