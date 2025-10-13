# frozen_string_literal: true


module Simple2DDemo
  # Add keyboard control to moving components.
  # This does not handle actual motion/animation, it only
  # registers and delegates controller input.
  module Steering
    STEERING_MAP = {
      "j" => :left,
      "l" => :right,
      "i" => :up,
      "," => :down,
      "u" => :up_left,
      "o" => :up_right,
      "m" => :down_left,
      "." => :down_right,
      "k" => :toggle_start,

      "left" => :left,
      "right"=> :right,
      "up"   => :up,
      "down" => :down,
      "space" => :toggle_start,

      "keypad 4" => :left,
      "keypad 6" => :right,
      "keypad 8" => :up,
      "keypad 2" => :down,
      "keypad 7" => :up_left,
      "keypad 9" => :up_right,
      "keypad 1" => :down_left,
      "keypad 3" => :down_right,
      "keypad 5" => :toggle_start
    }

    STEERING_KEYS = STEERING_MAP.keys

    attr_accessor :last_steering_input

    def self.included(base)
      def initialize(*args)
        # if base is e.g. MovingDot < GAME, then:
        # Game -> this -> MovingDot
        super(*args) # window

        # REFACTOR:try to avoid hard dependencies
        unless self.class.ancestors.map(&:name).include?("Simple2DDemo::Moving") &&
               self.window # Game
          raise ArgumentError, "Steering depends on Moving"
        end

        set_directional_inputs
      end
    end

    private

    def set_directional_inputs
      # FEATURE REQUEST: option for standard game-controller style, must hold down to move,
      # stop on key_up.
      window.on :key_down do |event|
        logger.debug { event }

        case event.key
        when *STEERING_KEYS
          self.last_steering_input = STEERING_MAP[event.key]
          direction!
        end
      end
    end

    def direction!
      self.controlled_objects.each do |obj|
        obj.direction!(self.last_steering_input) # Moving
      end
    end
  end
end
