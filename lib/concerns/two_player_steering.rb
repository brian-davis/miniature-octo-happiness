# frozen_string_literal: true
module Simple2DDemo
  # Add keyboard control to moving components.
  # This does not handle actual motion/animation, it only
  # registers and delegates controller input.
  module TwoPlayerSteering
    STEERING_MAP_LEFT = {
      "j" => :left,
      "l" => :right,
      "i" => :up,
      "," => :down,
      "u" => :up_left,
      "o" => :up_right,
      "m" => :down_left,
      "." => :down_right,
      "k" => :toggle_start,
    }
    STEERING_KEYS_LEFT = STEERING_MAP_LEFT.keys

    STEERING_MAP_RIGHT = {
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
    STEERING_KEYS_RIGHT = STEERING_MAP_RIGHT.keys

    attr_accessor :last_steering_input_left, :last_steering_input_right

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

    def controlled_objects_left
      @controlled_objects_left ||= moving_objects.select do |mo|
        mo.controlled && mo.controller == :left # Moveable
      end
    end

    def controlled_objects_right
      @controlled_objects_right ||= moving_objects.select do |mo|
        mo.controlled && mo.controller == :right # Moveable
      end
    end

    private

    def set_directional_inputs
      # FEATURE: option for standard game-controller style, must hold down to move,
      # stop on key_up.
      window.on :key_down do |event|
        logger.debug { event }

        case event.key
        when *STEERING_KEYS_LEFT
          self.last_steering_input_left = STEERING_MAP_LEFT[event.key]
          direction_left!
        when *STEERING_KEYS_RIGHT
          self.last_steering_input_right = STEERING_MAP_RIGHT[event.key]
          direction_right!
        end
      end
    end

    def direction_left!
      self.controlled_objects_left.each do |obj|
        obj.direction!(self.last_steering_input_left) # Moving
      end
    end

    def direction_right!
      self.controlled_objects_right.each do |obj|
        obj.direction!(self.last_steering_input_right) # Moving
      end
    end
  end
end
