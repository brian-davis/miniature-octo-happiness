# frozen_string_literal: true

module Simple2DDemo
  module Blocking
    # def self.included(base)
    # end

    attr_reader :blocking_update
    attr_accessor :blocks

    def initialize(*args)
      super(*args)

      # REFACTOR: try to avoid hard dependencies
      unless self.class.ancestors.map(&:name).include?("Simple2DDemo::Moving") &&
             self.class.ancestors.map(&:name).include?("Simple2DDemo::Colliding") &&
             self.window # Game
        raise ArgumentError, "Blocking depends on Moving and Colliding"
      end

      @blocking_update = method(:block_all)
      @blocks = []
    end

    def blocking_mode=(mode)
      unless BLOCKING_MODES.include?(mode)
        msg = "Invalid blocking_mode. Valid options: #{BLOCKING_MODES.join(', ')}"
        raise ArgumentError, msg
      end
      @blocking_mode = mode
    end

    private

    def block_all
      self.moving_objects.each do |obj| # Moving
        # IMPROVE: find more efficient boundary/block/collission detection
        blocker = blocks.detect { |block| obj.collides?(block) }

        # :reflect, :stop, :eliminate
        send(blocker.blocking_mode, obj, blocker) if blocker
      end
    end

    # Bouncing behavior, accounting for strike angle, like Pong.
    # Hit the wall going left, now you are going right.
    # REFACTOR: can this be simplified?
    def block_reflect(obj, blocker)
      logger.debug { "block_reflect" }

      ### get coordinates ###

      block_top_left, block_bottom_right = blocker.xy_coverage
      block_left   = block_top_left[0]
      block_right  = block_bottom_right[0]
      block_top    = block_top_left[1]
      block_bottom = block_bottom_right[1]
      block_x_center = ((block_left + block_right) / 2).round
      block_y_center = ((block_top + block_bottom) / 2).round

      logger.debug { "block_left: #{block_left}" }
      logger.debug { "block_right: #{block_right}" }
      logger.debug { "block_top: #{block_top}" }
      logger.debug { "block_bottom: #{block_bottom}" }
      logger.debug { "block_x_center: #{block_x_center}" }
      logger.debug { "block_y_center: #{block_y_center}" }

      obj_top_left, obj_bottom_right = obj.static_xy_coverage
      obj_left   = obj_top_left[0]
      obj_right  = obj_bottom_right[0]
      obj_x_center = ((obj_left + obj_right) / 2).round
      obj_top    = obj_top_left[1]
      obj_bottom = obj_bottom_right[1]
      obj_y_center = ((obj_top + obj_bottom) / 2).round

      logger.debug { "obj_left: #{obj_left}" }
      logger.debug { "obj_right: #{obj_right}" }
      logger.debug { "obj_x_center: #{obj_x_center}" }
      logger.debug { "obj_top: #{obj_top}" }
      logger.debug { "obj_bottom: #{obj_bottom}" }
      logger.debug { "obj_y_center: #{obj_y_center}" }

      ### get relative positions ###

      # Find general direction; is the obj up_left of the block?
      up_or_down = if obj_y_center < block_y_center
        :up
      elsif obj_y_center == block_y_center
        nil
      elsif obj_y_center > block_y_center
        :down
      end
      left_or_right = if obj_x_center < block_x_center
        :left
      elsif obj_x_center == block_x_center
        nil
      elsif obj_x_center > block_x_center
        :right
      end
      general_direction = [up_or_down,left_or_right].compact.join("_").to_sym
      logger.debug { "general_direction: #{general_direction}" }

      ### Find edge ###

      edge = case general_direction
      when :up_left
        obj_bottom <= block_top ? :top_edge : :left_edge
      when :up
        :top_edge
      when :up_right
        obj_bottom <= block_top ? :top_edge : :right_edge
      when :left
        :left_edge
      when :right
        :right_edge
      when :down_left
        obj_top <= block_bottom ? :left_edge : :bottom_edge
      when :down
        :bottom_edge
      when :down_right
        obj_top <= block_bottom ? :right_edge : :bottom_edge
      end

      logger.debug { "last_direction: #{obj.last_direction}; edge: #{edge}" }

      ### 12 possible angles: 3 angles (negative-straight-positive) * 4 edges

      reflection = if obj.last_direction == :down && edge == :top_edge
        :up
      elsif obj.last_direction == :up && edge == :bottom_edge
        :down
      elsif obj.last_direction == :left && edge == :right_edge
        :right
      elsif obj.last_direction == :right && edge == :left_edge
        :left
      elsif obj.last_direction == :up_left && edge == :right_edge
        :up_right
      elsif obj.last_direction == :up_left && edge == :bottom_edge
        :down_left
      elsif obj.last_direction == :up_right && edge == :left_edge
        :up_left
      elsif obj.last_direction == :up_right && edge == :bottom_edge
        :down_right
      elsif obj.last_direction == :down_right && edge == :left_edge
        :down_left
      elsif obj.last_direction == :down_right && edge == :top_edge
        :up_right
      elsif obj.last_direction == :down_left && edge == :right_edge
        :down_right
      elsif obj.last_direction == :down_left && edge == :top_edge
        :up_left
      end

      obj.direction!(reflection) if reflection
    end

    def block_stop(obj, _block)
      logger.debug { "block_stop" }
      obj.stop!
    end

    def block_eliminate(obj, _block)
      logger.debug { "block_eliminate" }
      remove_object(obj) # Moving
    end
  end
end
