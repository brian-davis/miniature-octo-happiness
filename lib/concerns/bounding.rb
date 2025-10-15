# frozen_string_literal: true
module Simple2DDemo
  # IMPROVE: Review, avoid mutual dependencies between Moving, Colliding, Bounding
  module Bounding
    BOUNDING_MODES = [:unbounded, :wrap, :reflect, :stop, :eliminate]

    # def self.included(base)
    # end

    attr_reader :bounding_update, :bounding_mode
    attr_accessor :edge_size

    def initialize(*args)
      super(*args)
      self.update_actions.push(:bound_all)

      @bounding_mode = BOUNDING_MODES.first # reset after init
      @edge_size = 0 # reset after init
    end

    def bounding_mode=(mode)
      unless BOUNDING_MODES.include?(mode)
        msg = "Invalid bounding_mode. Valid options: #{BOUNDING_MODES.join(', ')}"
        raise ArgumentError, msg
      end
      @bounding_mode = mode
    end

    private

    def bound_all
      self.moving_objects.each do |obj|
        edge = out_of_bounds?(obj)
        # :unbounded, :wrap, :reflect, :stop, :eliminate
        send(bounding_mode, obj, edge) if edge
      end
    end

    # For differing edge behavior (e.g. top, bottom reflect, left, right eliminate)
    # use walls (e.g. Pong)
    def out_of_bounds?(obj)
      top_left, bottom_right = obj.xy_coverage # Collidable

      return :top_edge    if top_left[1] <= edge_size
      return :right_edge  if bottom_right[0] >= window_width - edge_size
      return :bottom_edge if bottom_right[1] >= window_height - edge_size
      return :left_edge   if top_left[0] <= edge_size
    end

    # :unbounded lets you go as far as you want off-screen,
    # no indication how to get back. Not recommended.
    def unbounded(_obj, _edge)
      logger.debug { "unbounded" }
      # do nothing
    end

    # Globe-like behavior, like Pac-man.
    # Hit the wall going left, now emerge from the right, still moving left.
    def wrap(obj, edge)
      logger.debug { "wrap" }
      case edge
      when :left_edge
        obj.x = window_width - edge_size - obj.size
      when :right_edge
        # OK
        obj.x = edge_size
      when :top_edge
        obj.y = window_height - edge_size - obj.size
      when :bottom_edge
        # OK
        obj.y = edge_size
      end
    end

    # used by :reflect and by :stop
    def reflection_match(obj, edge)
      case [obj.last_direction, edge]
      in [:left, :left_edge]
        :right
      in [:right, :right_edge]
        :left
      in [:up, :top_edge]
        :down
      in [:down, :bottom_edge]
        :up
      in [:up_left, :left_edge]
        :up_right
      in [:up_left, :top_edge]
        :down_left
      in [:up_right, :right_edge]
        :up_left
      in [:up_right, :top_edge]
        :down_right
      in [:down_left, :left_edge]
        :down_right
      in [:down_left, :bottom_edge]
        :up_left
      in [:down_right, :right_edge]
        :down_left
      in [:down_right, :bottom_edge]
        :up_right
      else
        nil
      end
    end

    # Bouncing behavior, accounting for strike angle, like Pong.
    # Hit the wall going left, now you are going right.
    # IMPROVE: Duplicate logic between this and BlockReflection
    def reflect(obj, edge)
      logger.debug { "reflect" }
      reflection = reflection_match(obj, edge)
      obj.direction!(reflection) if reflection
    end

    def stop(obj, edge)
      logger.debug { "stop" }
      # if you hit the wall going left, stop from going further left
      # else allow to go right
      reflection = reflection_match(obj, edge)
      obj.stop! if reflection
    end

    def eliminate(obj, _edge)
      logger.debug { "eliminate" }
      remove_object(obj) # Moving
    end
  end
end
