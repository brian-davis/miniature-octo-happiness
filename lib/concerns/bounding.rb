# frozen_string_literal: true

module Boundable
  # assume Square
  alias_method :bounding_coordinates, def x_y_size
    [x, y, size]
  end
end

module Bounding
  # REFACTOR: break out boundary and/or collision logic into separate module(s)
  BOUNDING_MODES = [:unbounded, :wrap, :reflect, :stop, :eliminate]

  def self.included(base)
    attr_reader :bounding_update_callback, :bounding_mode
    attr_accessor :edge_size

    def initialize(*args)
      super(*args)

      # REFACTOR:try to avoid hard dependencies
      unless self.class.ancestors.map(&:to_s).include?("Moving") &&
             self.class.ancestors.map(&:to_s).include?("Steering") &&
             self.window # Game
        raise ArgumentError, "Bounding depends on Moving and Steering"
      end

      @bounding_mode = BOUNDING_MODES.first # reset after init
      @bounding_update_callback = method(:bound_all)
      @edge_size = 0 # reset after init
    end
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
    # Moving dependency
    self.moving_objects.each do |obj|
      obj_oob = out_of_bounds?(*obj.bounding_coordinates)
      send(bounding_mode, obj, obj_oob) if obj_oob
    end
  end

  # FEATURE REQUEST: allow for differing edge behavior
  # e.g. Arkanoid top/left/right edges bouce, bottom edge eliminates
  def out_of_bounds?(x, y, s)
    return :top_edge    if top_edge?(x, y, s)
    return :right_edge  if right_edge?(x, y, s)
    return :bottom_edge if bottom_edge?(x, y, s)
    return :left_edge   if left_edge?(x, y, s)
  end

  def top_edge?(_x, y, _s)
    y <= edge_size # size not necessary (square not centered)
  end

  def right_edge?(x, _y, s)
    x >= window_width - s - edge_size # size necessary (square not centered)
  end

  def bottom_edge?(_x, y, s)
    y >= window_height - s - edge_size # s necessary (square not centered)
  end

  def left_edge?(x, _y, _s)
    x <= edge_size # _s not necessary (square not centered)
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
      obj.x = window_width - edge_size
    when :right_edge
      obj.x = edge_size
    when :top_edge
      obj.y = window_height - edge_size
    when :bottom_edge
      obj.y = edge_size
    end
  end

  # Bouncing behavior, accounting for strike angle, like Pong.
  # Hit the wall going left, now you are going right.
  def reflect(obj, edge)
    logger.debug { "reflect" }

    # REFACTOR
    new_motion = case obj.last_direction
    when :left
      :right
    when :right
      :left
    when :up
      :down
    when :down
      :up
    when :up_left
      if edge == :left_edge
        :up_right
      elsif edge == :top_edge
        :down_left
      end
    when :up_right
      if edge == :right_edge
        :up_left
      elsif edge == :top_edge
        :down_right
      end
    when :down_left
      if edge == :left_edge
        :down_right
      elsif edge == :bottom_edge
        :up_left
      end
    when :down_right
      if edge == :right_edge
        :down_left
      elsif edge == :bottom_edge
        :up_right
      end
    end

    obj.direction!(new_motion)
  end

  def stop(obj, _edge)
    logger.debug { "stop" }
    obj.full_stop! # DEBUG
  end

  def eliminate(obj, _edge)
    logger.debug { "eliminate" }
    remove_object(obj)
  end
end