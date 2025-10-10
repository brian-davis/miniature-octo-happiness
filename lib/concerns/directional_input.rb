# frozen_string_literal: true

# REFACTOR: Use hierarchical module namespacing

# Add keyboard control to moving components.
# This does not handle actual motion/animation, it only
# registers and delegates controller input.
module DirectionalInput
  DIRECTIONAL_INPUT_MAP = {
    "j" => :left,
    "l" => :right,
    "i" => :up,
    "," => :down,
    "u" => :up_left,
    "o" => :up_right,
    "m" => :down_left,
    "." => :down_right,

    "left" => :left,
    "right"=> :right,
    "up"   => :up,
    "down" => :down,

    "keypad 4" => :left,
    "keypad 6" => :right,
    "keypad 8" => :up,
    "keypad 2" => :down,
    "keypad 7" => :up_left,
    "keypad 9" => :up_right,
    "keypad 1" => :down_left,
    "keypad 3" => :down_right
  }
  DIRECTIONAL_INPUT_KEYS = DIRECTIONAL_INPUT_MAP.keys

  attr_accessor :last_directional_input

  def self.included(base)
    def initialize(*args)
      # if base is e.g. MovingDot, then:
      # Game -> this -> MovingDot
      super(*args) # window

      raise NotImplementedError, "Superclass must set @window" unless window
      set_directional_inputs
    end
  end

  private

  def set_directional_inputs
    window.on :key_down do |event|
      logger.debug event

      case event.key
      when *DIRECTIONAL_INPUT_KEYS
        self.last_directional_input = DIRECTIONAL_INPUT_MAP[event.key]
        direction!
      end
    end
  end

  def direction!
    method_name = "#{last_directional_input}!"
    logger.debug method_name
    send(method_name) if last_directional_input
  end

  ### TEMPLATE METHODS ###

  def left!
    raise NotImplementedError, "Subclass must define :left! method."
  end

  def right!
    raise NotImplementedError, "Subclass must define :right! method."
  end

  def up!
    raise NotImplementedError, "Subclass must define :up! method."
  end

  def down!
    raise NotImplementedError, "Subclass must define :down! method."
  end

  def up_left!
    raise NotImplementedError, "Subclass must define :up_left! method."
  end

  def up_right!
    raise NotImplementedError, "Subclass must define :up_right! method."
  end

  def down_left!
    raise NotImplementedError, "Subclass must define :down_left! method."
  end

  def down_right!
    raise NotImplementedError, "Subclass must define :down_right! method."
  end
end