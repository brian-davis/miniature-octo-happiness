# REFACTOR: standard bundled gem structure
require_relative "../lib/game"

class Array
  # Convert an array into a cycle object which will not
  # make a jarring leap from last place to first place,
  # or have a doubling effect at the extremes.
  # e.g.
  # [1,2,3,4] => (1,2,3,4,3,2,1,2,3,4,3,2 ...)
  def gradient_cycle
    return nil if empty?
    up_half = self.dup
    down_half = up_half[1...-1].reverse
    (up_half + down_half).cycle
  end
end

class MovingDot < Game
  DEFAULT_DOT_COLOR = "#ffffff"
  DEFAULT_PULSE_VALUES = [
    "#000000",
    "#111111",
    "#222222",
    "#333333",
    "#444444",
    "#555555",
    "#666666",
    "#777777",
    "#888888",
    "#999999",
    "#aaaaaa",
    "#bbbbbb",
    "#cccccc",
    "#dddddd",
    "#eeeeee",
    "#ffffff"
  ]
  DEFAULT_BOUNDARY_BEHAVIOR = "pong"
  DEFAULT_DOT_RATE = 2
  DEFAULT_PULSE_RATE = 10
  MAX_TICK = 2 ** 63 - 1

  # REFACTOR: break out motion logic into separate module
  MOTION_MAP = {
    "j" => :left,
    "l" => :right,
    "i" => :up,
    "," => :down,
    "u" => :up_left,
    "o" => :up_right,
    "m" => :down_left,
    "." => :down_right,

    "left"     => :left,
    "right"    => :right,
    "up"       => :up,
    "down"     => :down,

    "keypad 4" => :left,
    "keypad 6" => :right,
    "keypad 8" => :up,
    "keypad 2" => :down,
    "keypad 7" => :up_left,
    "keypad 9" => :up_right,
    "keypad 1" => :down_left,
    "keypad 3" => :down_right
  }
  MOTION_KEYS = MOTION_MAP.keys

  # REFACTOR: break out boundary and/or collision logic into separate module(s)
  BOUNDARY_BEHAVIORS = ["pacman", "pong", "stop", "unbounded"]

  attr_reader :dot, :dot_size, :pulse_cycle, :pulse_rate, :straight_rate, :diagonal_rate, :boundary_behavior, :enable_pulse

  attr_accessor :tick, :x_speed, :y_speed, :last_motion

  def initialize(*args)
    super(*args)

    # state machine
    @tick    = 0
    @x_speed = 0
    @y_speed = 0
    @last_motion = nil

    set_pulse
    set_dot
    set_motion
    set_boundary_behavior
    set_inputs
    set_game_loop
  end

  private

  ### SET UP ###

  def set_dot
    @dot = Square.new(
      x: window_center_x,
      y: window_center_y,
      size: config["dot_size"]
    )
    if enable_pulse
      self.dot.color = pulse_cycle.next
    else
      color = config["dot_color"] || DEFAULT_DOT_COLOR
      self.dot.color = color
    end
    @dot_size = @dot.size
    logger.info "dot_size:\t#{self.dot_size}"
  end

  def set_pulse
    @enable_pulse = !config["pulse_off"]
    return unless enable_pulse

    pulse_values = config["pulse_values"] || DEFAULT_PULSE_VALUES # array of strings for color hex-values
    logger.info "pulse_values:\t#{pulse_values.join(', ')}"
    @pulse_cycle = pulse_values.gradient_cycle

    @pulse_rate = config["pulse_rate"] || DEFAULT_PULSE_RATE
    logger.info "pulse_rate:\t#{pulse_rate}"
  end

  def set_motion
    # Motion u/d/l/r
    @straight_rate = config["dot_rate"] || DEFAULT_DOT_RATE
    logger.info "straight_rate:\t#{straight_rate}"

    # Motion ul/ur/dl/dr
    calc = straight_rate - (
      1 / Math.sqrt(2 * (straight_rate ** 2))
    ) # DEBUG: correct math?

    @diagonal_rate = calc
    logger.info "diagonal_rate:\t#{diagonal_rate}"
  end

  def set_boundary_behavior
    @boundary_behavior = begin
      config_val = config["boundary_behavior"]
      if BOUNDARY_BEHAVIORS.include?(config_val)
        logger.info "boundary_behavior:\t#{config_val}"
        config_val
      else
        logger.error "boundary_behavior configuration:\t \
        Bad value. Valid options: #{BOUNDARY_BEHAVIORS.join(', ')}"

        DEFAULT_BOUNDARY_BEHAVIOR
      end
    end
  end

  def set_inputs
    window.on :key_down do |event|
      logger.debug event
      case event.key
      when "space", "keypad 5", "k"
        # REFACTOR: can this be moved into MOTION_MAP?
        toggle_stop_start
      when *MOTION_KEYS
        last_motion!(MOTION_MAP[event.key])
        start!
      end
    end
  end

  def set_game_loop
    window.update do
      enable_pulse && pulse!
      move!
    end
  end

  ### STATE MACHINE ###

  def stopped?
    x_speed == 0 && y_speed == 0
  end

  def moving?
    !stopped?
  end

  def speed!(x, y)
    logger.debug "speed!(#{x},#{y})"
    self.x_speed, self.y_speed = x, y
  end

  # REFACTOR: don't duplicate behavior between motion and boundary concerns.
  # :stop is a sticky wall. Can't slide along the edge.
  # That's friction!
  def stop!
    logger.debug "stop!"
    speed!(0, 0)
  end

  def start!
    logger.debug "start!"
    send("#{last_motion}!") if last_motion
  end

  def toggle_stop_start
    logger.debug "toggle_stop_start"
    moving? ? stop! : start!
  end

  def left!
    logger.debug "left!"
    speed!(-straight_rate, 0)
  end

  def right!
    logger.debug "right!"
    speed!(straight_rate, 0)
  end

  def up!
    logger.debug "up!"
    speed!(0, -straight_rate)
  end

  def down!
    logger.debug "down!"
    speed!(0, straight_rate)
  end

  def up_left!
    logger.debug "up_left!"
    speed!(-diagonal_rate, -diagonal_rate)
  end

  def up_right!
    logger.debug "up_right!"
    speed!(diagonal_rate, -diagonal_rate)
  end

  def down_left!
    logger.debug "down_left!"
    speed!(-diagonal_rate, diagonal_rate)
  end

  def down_right!
    logger.debug "down_right!"
    speed!(diagonal_rate, diagonal_rate)
  end

  def top_edge?
    dot.y <= dot_size
  end

  def right_edge?
    dot.x >= (window_width - dot_size)
  end

  def bottom_edge?
    dot.y >= (window_height - dot_size)
  end

  def left_edge?
    dot.x <= dot_size
  end

  def out_of_bounds?
    top_edge? || right_edge? || bottom_edge? || left_edge?
  end

  # :pacman will produce virtual-globe behavior.
  # Hit the wall going left, now emerge from the right, still moving left.
  def pacman!
    logger.debug "pacman!"
    if left_edge?
      self.dot.x = window_width - dot_size
    elsif right_edge?
      self.dot.x = dot_size
    elsif top_edge?
      self.dot.y = window_height - dot_size
    elsif bottom_edge?
      self.dot.y = dot_size
    end
  end

  # :pong will produce bouncing behavior.
  # Hit the wall going left, now you are going right.
  def pong!
    logger.debug "pong!"
    stop!
    motion = case last_motion
    when :left
      :right
    when :right
      :left
    when :up
      :down
    when :down
      :up
    when :up_left
      if left_edge?
        :up_right
      elsif top_edge?
        :down_left
      end
    when :up_right
      if right_edge?
        :up_left
      elsif top_edge?
        :down_right
      end
    when :down_left
      if left_edge?
        :down_right
      elsif bottom_edge?
        :up_left
      end
    when :down_right
      if right_edge?
        :down_left
      elsif bottom_edge?
        :up_right
      end
    end
    last_motion!(motion)
    start!
  end

  # :unbounded lets you go as far as you want off-screen,
  # no indication how to get back. Not recommended.
  def unbounded!
    logger.debug "unbounded!"
    # do nothing
  end

  # Animate motion of dot across the window.
  # Called from main loop.
  def move!
    self.dot.x += x_speed
    self.dot.y += y_speed
    send("#{boundary_behavior}!") if out_of_bounds?
  end

  # pulsing or shifting effect on the dot appearance
  # Called from main loop.
  def pulse!
    # 60 cycles per second
    if tick % pulse_rate == 0
      self.dot.color = pulse_cycle.next
    end

    # no Integer::MAX in newer rubies, but try to prevent memory overflow
    # https://stackoverflow.com/a/60828820
    # https://stackoverflow.com/a/43040560
    self.tick = 0 if self.tick >= MAX_TICK
    self.tick += 1
  end

  def last_motion!(motion)
    logger.debug "last_motion!#{motion}"
    self.last_motion = motion if motion
  end
end