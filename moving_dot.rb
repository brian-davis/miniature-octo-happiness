# frozen_string_literal: true
require "ruby2d"
require "json"

$config = JSON.load_file("moving_dot_config.json")

FRAME_WIDTH  = $config["frame_width"]
FRAME_HEIGHT = $config["frame_height"]

FRAME_TITLE  = "MOVING DOT"

FRAME_CENTER_Y = FRAME_HEIGHT / 2
FRAME_CENTER_X = FRAME_WIDTH / 2

DOT_SIZE          = $config["dot_size"]
DOT_RATE_OF_SPEED = $config["dot_rate_of_speed"]

# DEBUG: correct math here?
# Decimal values are OK, no need to DIY exact pixel placement
DOT_DIAGONAL_RATE_OF_SPEED = Math.sqrt(2) / Math.sqrt(2 * (DOT_RATE_OF_SPEED ** 2))

MOTION_MAP = {
  "j"        => :left,
  "left"     => :left,
  "keypad 4" => :left,

  "l"        => :right,
  "right"    => :right,
  "keypad 6" => :right,

  "i"        => :up,
  "up"       => :up,
  "keypad 8" => :up,

  "k"        => :down,
  "down"     => :down,
  "keypad 2" => :down,

  "keypad 7" => :up_left,
  "keypad 9" => :up_right,
  "keypad 1" => :down_left,
  "keypad 3" => :down_right
}
MOTION_KEYS = MOTION_MAP.keys

BOUNDARY_BEHAVIORS = ["pacman", "pong", "stop", "unbounded"]

PULSE_RATE = 10
PULSE_VALUES      = $config["pulse_values"]
PULSE_RANGE_LEFT  = [$config["pulse_range_left"], 0].max
PULSE_RANGE_RIGHT = [$config["pulse_range_right"], (PULSE_VALUES.length - 1)].min
@pulse_range = (PULSE_RANGE_LEFT..PULSE_RANGE_RIGHT)

@pulse_cycle = (
  (first_half = PULSE_VALUES[@pulse_range]) + first_half[1...-1].reverse
).cycle

@dot = Square.new(
  x: FRAME_CENTER_X,
  y: FRAME_CENTER_Y,
  size: DOT_SIZE,
  color: @pulse_cycle.next
)

@tick = 0

@x_speed = 0
@y_speed = 0
@last_motion = nil

@boundary_behavior = $config["boundary_behavior"]

unless BOUNDARY_BEHAVIORS.include?(@boundary_behavior)
  raise "Bad config for 'boundary_behavior'. Valid options: #{BOUNDARY_BEHAVIORS.join(', ')}"
end

def stopped?
  @x_speed == 0 && @y_speed == 0
end

def moving?
  !stopped?
end

def speed!(x, y)
  @x_speed, @y_speed = x, y
end

# :stop, called from :wrap!, is a sticky wall. Can't slide along the edge.
# That's friction!
def stop!
  speed!(0, 0)
end

def start!
  self.send("#{@last_motion}!") if @last_motion
end

def toggle_stop_start
  moving? ? stop!() : start!()
end

def left!
  speed!(-DOT_RATE_OF_SPEED, 0)
end

def right!
  speed!(DOT_RATE_OF_SPEED, 0)
end

def up!
  speed!(0, -DOT_RATE_OF_SPEED)
end

def down!
  speed!(0, DOT_RATE_OF_SPEED)
end

def up_left!
  speed!(-DOT_RATE_OF_SPEED, -DOT_RATE_OF_SPEED)
end

def up_right!
  speed!(DOT_RATE_OF_SPEED, -DOT_RATE_OF_SPEED)
end

def down_left!
  speed!(-DOT_RATE_OF_SPEED, DOT_RATE_OF_SPEED)
end

def down_right!
  speed!(DOT_RATE_OF_SPEED, DOT_RATE_OF_SPEED)
end

def top_edge?
  @dot.y <= DOT_SIZE
end

def right_edge?
  @dot.x >= (FRAME_WIDTH - DOT_SIZE)
end

def bottom_edge?
  @dot.y >= (FRAME_HEIGHT - DOT_SIZE)
end

def left_edge?
  @dot.x <= DOT_SIZE
end

def out_of_bounds?
  top_edge? || right_edge? || bottom_edge? || left_edge?
end

def wrap!
  self.send("#{@boundary_behavior}!")
end

# :pacman, called from wrap! will produce virtual-globe behavior.
# Hit the wall going left, now emerge from the right, still moving left.
def pacman!
  if left_edge?
    @dot.x = FRAME_WIDTH - DOT_SIZE
  elsif right_edge?
    @dot.x = DOT_SIZE
  elsif top_edge?
    @dot.y = FRAME_HEIGHT - DOT_SIZE
  elsif bottom_edge?
    @dot.y = DOT_SIZE
  end
end

# :pong, called from wrap! will produce bouncing behavior.
# Hit the wall going left, now you are going right.
def pong!
  stop!
  motion = case @last_motion
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

# :unbounded, called from wrap! lets you go as far as you want off-screen,
# no indication how to get back. Not recommended.
def unbounded!
  # do nothing
end

def move!
  @dot.x += @x_speed
  @dot.y += @y_speed
  wrap! if out_of_bounds?
end

# pulsing or shifting effect on the dot appearance
def pulse!
  # 60 cycles per second
  if @tick % PULSE_RATE == 0
    @dot.color = @pulse_cycle.next
  end
end

def last_motion!(motion)
  @last_motion = motion if motion
end

Window.set(
  title:  FRAME_TITLE,
  width:  FRAME_WIDTH,
  height: FRAME_HEIGHT
)

Window.on :key_down do |event|
  # puts(event)
  case event.key
  when "space"
    toggle_stop_start()
  when "q"
    exit()
  when *MOTION_KEYS # slight performance hit vs. hard-coding
    last_motion!(MOTION_MAP[event.key])
    start!()
  end
end

Window.update do
  move!()
  pulse!()
  @tick += 1
end

welcome =  <<~TEXT

Welcome to moving_dot.rb. You should see a game window with a cursor point.
Move the cursor using 9-key numpad, up/down/left/right arrow keys, or i/k/j/l keys.
Press the space bar to start or stop.
Press Q to quit.

Try adjusting config options in JSON, such as 'boundary_behavior' with options: #{BOUNDARY_BEHAVIORS}

TEXT

puts welcome

Window.show()
