# frozen_string_literal: true

require_relative "../helpers/gradients"

module Simple2DDemo
  # Add pulse/gradient functionality to a Game subclass.
  module Pulsing
    # include into Game subclass (with .window object)

    # no Integer::MAX in newer rubies, but try to prevent memory overflow
    # https://stackoverflow.com/a/60828820
    # https://stackoverflow.com/a/43040560
    MAX_TICK = 2 ** 63 - 1 # 60 cycles per second

    def self.included(base)
    end

    attr_reader :enable_pulse, :pulsing_update
    attr_accessor :pulsing_objects, :pulse_tick
    def initialize(*args)
      # if base is e.g. StarField < Game, then:
      # Game -> this -> StarField
      super(*args)
      self.update_actions.push(:pulse_all)

      @enable_pulse = config["enable_pulse"] # Game
      logger.info {"config enable pulse: #{@enable_pulse}"}
      @pulse_tick = 0
      @pulsing_objects = []
      remove_observables.push(:pulsing_objects)
    end

    private

    def pulse_all
      return unless enable_pulse
      pulsing_objects.each do |pulsing_object|
        if pulse_tick % pulsing_object.pulse_rate == 0
          # e.g. Square, with .color method
          # REFACTOR: make this settable
          pulsing_object.color = pulsing_object.pulse_cycle.next
        end
      end

      self.pulse_tick = 0 if self.pulse_tick >= MAX_TICK
      self.pulse_tick += 1
    end
  end
end
