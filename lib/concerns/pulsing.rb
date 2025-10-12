# frozen_string_literal: true

require_relative "../helpers/gradients"

# Add pulse/gradient functionality to a Game subclass.
module Pulsing
  # include into Game subclass (with .window object)

  # no Integer::MAX in newer rubies, but try to prevent memory overflow
  # https://stackoverflow.com/a/60828820
  # https://stackoverflow.com/a/43040560
  MAX_TICK = 2 ** 63 - 1 # 60 cycles per second

  def self.included(base)
    attr_reader :enable_pulse, :pulsing_update
    attr_accessor :pulse_items, :pulse_tick

    def initialize(*args)
      # if base is e.g. StarField < Game, then:
      # Game -> this -> StarField
      super(*args)
      @enable_pulse = config["enable_pulse"] # Game
      logger.info {"config enable pulse: #{@enable_pulse}"}
      @pulse_tick = 0
      @pulse_items = []
      @pulsing_update = method(:pulse_all)
    end
  end

  private

  def pulse_all
    return unless enable_pulse
    pulse_items.each do |pulse_item|
      if pulse_tick % pulse_item.pulse_rate == 0
        # e.g. Square, with .color method
        # REFACTOR: make this settable
        pulse_item.color = pulse_item.pulse_cycle.next
      end
    end

    self.pulse_tick = 0 if self.pulse_tick >= MAX_TICK
    self.pulse_tick += 1
  end
end