require_relative "../helpers/gradients"

# Add pulse/gradient functionality to an element within Game subclass.
# Re-open and include as necessary. example (from star_field.rb):
# class Ruby2D::Square
#   include Pulseable
# end
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

# Add pulse/gradient functionality to a Game subclass.
module Pulsing
  # include into Game subclass (with .window object)

  # no Integer::MAX in newer rubies, but try to prevent memory overflow
  # https://stackoverflow.com/a/60828820
  # https://stackoverflow.com/a/43040560
  MAX_TICK = 2 ** 63 - 1 # 60 cycles per second

  def self.included(base)
    attr_reader :enable_pulse, :pulse_update_callback, :pulse_tick
    attr_accessor :pulse_items

    def initialize(*args)
      # if base is e.g. StarField < Game, then:
      # Game -> this -> StarField
      super(*args)
      @enable_pulse = config["enable_pulse"] # Game
      logger.info "config enable pulse: #{@enable_pulse}"
      @pulse_tick = 0
      @pulse_items = []

      # including Game can call from `update` singleton
      @pulse_update_callback = method(:pulse!)
    end
  end

  private

  def pulse!
    pulse_items.each do |pulse_item|
      if pulse_tick % pulse_item.pulse_rate == 0
        # e.g. Square, with .color method
        pulse_item.color = pulse_item.pulse_cycle.next
      end
    end

    self.pulse_tick = 0 if self.pulse_tick >= MAX_TICK
    @pulse_tick += 1
  end
end