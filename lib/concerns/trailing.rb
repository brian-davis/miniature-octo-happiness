# frozen_string_literal: true

module Simple2DDemo
  # Add trailing functionality to a Game subclass.
  module Trailing
    # include into Game subclass (with .window object)

    DEFAULT_TRAIL_LENGTH = 4
    MAX_TRAIL_TICKS = 60

    def self.included(base)
      unless base.ancestors.map(&:name).include?("Simple2DDemo::Game")
        raise ArgumentError, "Trailing depends on Game"
      end
    end

    attr_reader :enable_trail, :trailing_update
    attr_accessor :trailing_objects, :trailed_objects

    def initialize(*args)
      # if base is e.g. StarField < Game, then:
      # Game -> this -> StarField
      super(*args)
      self.update_actions.push(:trail_all)

      @enable_trail = config["enable_trail"] # Game
      logger.info {"config enable trail: #{@enable_trail}"}

      # moving objects which leave a trail
      @trailing_objects = []

      # static objects which are the trail left by a :trailing_object
      @trailed_objects = []

      @trail_length = config["trail_length"] || DEFAULT_TRAIL_LENGTH
      logger.info {"@trail_length #{@trail_length}"}

      remove_observables.push(:trailing_objects)
    end

    private

    def trail_all
      return unless enable_trail
      trailing_objects.each do |trailing_object|
        if master_tick % (trailing_object.trail_density * 2) == 0
          trailed = trailing_object.trail!(master_tick)
          trailed_objects.push(trailed)
        end
      end

      trailed_objects.each do |trailed_object|
        if master_tick % trailed_object.trail_density == 0
          trailed_object.fade!
        end

        if master_tick - trailed_object.initial_tick >= MAX_TRAIL_TICKS
          remove_object(trailed_object)
        end
      end
    end
  end
end
