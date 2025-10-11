# frozen_string_literal: true

module Bounding
  BOUNDING_MODES = [:unbounded, :wrap, :reflect, :stop, :eliminate]

  def self.included(base)
    attr_reader :bounding_update, :bounding_mode
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
      @bounding_update = method(:bound_all)
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
    self.moving_objects.each do |obj|
      edge = out_of_bounds?(*obj.bounding_coordinates)
      # :unbounded, :wrap, :reflect, :stop, :eliminate
      send(bounding_mode, obj, edge) if edge
    end
  end

  # FEATURE REQUEST: allow for differing edge behavior
  # e.g. Arkanoid top/left/right edges bouce, bottom edge eliminates
  def out_of_bounds?(x, y, s)
    return :top_edge    if y <= edge_size
    return :right_edge  if x >= window_width - s - edge_size
    return :bottom_edge if y >= window_height - s - edge_size
    return :left_edge   if x <= edge_size
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
    remove_object(obj)
  end
end