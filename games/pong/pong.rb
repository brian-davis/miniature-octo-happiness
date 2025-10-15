# frozen_string_literal: true

# Two moving paddles under user control play ping-pong with a small
# cursor object. If it goes past the edge of the window on the left or right, the game ends.
class Pong < Simple2DDemo::Game
  include Simple2DDemo::Pulsing
  include Simple2DDemo::Moving
  include Simple2DDemo::TwoPlayerSteering
  include Simple2DDemo::Colliding
  include Simple2DDemo::Bounding

  DEFAULT_PADDLE_COLOR = Simple2DDemo::Gradients::COMMON_COLOR_CODES["white"]
  DEFAULT_PADDLE_HEIGHT = 100
  DEFAULT_PADDLE_RATE = 4
  DEFAULT_PADDLE_WIDTH = 20

  DEFAULT_SHUTTLE_COLOR = Simple2DDemo::Gradients::COMMON_COLOR_CODES["white"]
  DEFAULT_SHUTTLE_RATE = 4
  DEFAULT_SHUTTLE_SIZE = 4

  DEFAULT_WALL_COLOR = Simple2DDemo::Gradients::COMMON_COLOR_CODES["gray"]
  DEFAULT_WALL_WIDTH = 10

  attr_accessor :wall_width, :wall_color,
                :paddle_color, :paddle_height, :paddle_width, :paddle_rate,
                :shuttle_rate, :shuttle_size, :shuttle_color

  def initialize(*args)
    super(*args)

    pong_defaults
    set_shuttle
    set_walls
    set_paddles
    set_start_input
  end

  private

  def pong_defaults
    self.bounding_mode = :eliminate

    self.paddle_color  = config["paddle_color"]  || DEFAULT_PADDLE_COLOR
    self.paddle_height = config["paddle_height"] || DEFAULT_PADDLE_HEIGHT
    self.paddle_width  = config["paddle_width"]  || DEFAULT_PADDLE_WIDTH
    self.paddle_rate   = config["paddle_rate"]   || DEFAULT_PADDLE_RATE

    self.shuttle_color = config["shuttle_color"] || DEFAULT_SHUTTLE_COLOR
    self.shuttle_size  = config["shuttle_size"]  || DEFAULT_SHUTTLE_SIZE
    self.shuttle_rate  = config["shuttle_rate"]  || DEFAULT_SHUTTLE_RATE

    self.wall_width    = config["wall_width"]    || DEFAULT_WALL_WIDTH
    self.wall_color    = config["wall_color"]    || DEFAULT_WALL_COLOR
  end

  def set_start_input
    window.on :key_down do |event|
      logger.debug { event }
      case event.key
      when "space"
        dir = (Simple2DDemo::Moveable.valid_directions - [:up, :down]).sample
        @shuttle.start!(dir)
      end
    end
  end

  def set_shuttle
    x, y = window.center
    shuttle_size = config["shuttle_size"] || DEFAULT_SHUTTLE_SIZE
    logger.info {"shuttle_size:\t#{shuttle_size}"}
    @shuttle = Simple2DDemo::Shuttle.new(
      x: x,
      y: y,
      size: shuttle_size
    )

    if config["engable_pulse"]
      cpv = config["pulse_values"]
      if cpv.nil? || cpv.empty?
        @shuttle.pulse_values = Simple2DDemo::Gradients.random_color_gradient
      else
        cpv
      end
      @shuttle.pulse_rate = config["pulse_rate"]
      @shuttle.color = @shuttle.pulse_cycle.next
      self.pulsing_objects.push(@shuttle)
    else
      @shuttle.color = self.shuttle_color
    end

    @shuttle.rate = config["shuttle_rate"]
    @shuttle.controlled = false
    self.moving_objects.push(@shuttle)
    @shuttle.collidable_mode = :reflect
    @shuttle.eliminate_callback = method(:remove_object) # IMPROVE: is there a better way to do this?

    self.colliding_objects.push(@shuttle)
    self.game_enders.push(@shuttle)
  end

  def set_walls
    @top_wall = Simple2DDemo::Wall.new(
      x: 0,
      y: 0,
      width: window.width,
      height: wall_width,
      color: wall_color
    )
    @top_wall.collidable_mode = :block
    self.colliding_objects.push(@top_wall)

    @top_left_wall = Simple2DDemo::Wall.new(
      x: 0,
      y: @top_wall.height, # FIX: overlap error
      width: wall_width,
      height: paddle_height,
      color: wall_color
    )
    @top_left_wall.collidable_mode = :block
    self.colliding_objects.push(@top_left_wall)

    @top_right_wall = Simple2DDemo::Wall.new(
      x: window.width - wall_width,
      y: @top_wall.height, # FIX: overlap error
      width: wall_width,
      height: paddle_height,
      color: wall_color
    )
    @top_right_wall.collidable_mode = :block
    self.colliding_objects.push(@top_right_wall)

    @bottom_wall = Simple2DDemo::Wall.new(
      x: 0,
      y: window.height - wall_width,
      width: window.width,
      height: wall_width,
      color: wall_color
    )
    @bottom_wall.collidable_mode = :block
    self.colliding_objects.push(@bottom_wall)

    @bottom_left_wall = Simple2DDemo::Wall.new(
      x: 0,
      y: window.height - @bottom_wall.height - paddle_height,
      width: wall_width,
      height: paddle_height,
      color: wall_color
    )
    @bottom_left_wall.collidable_mode = :block
    self.colliding_objects.push(@bottom_left_wall)

    @bottom_right_wall = Simple2DDemo::Wall.new(
      x: window.width - wall_width,
      y: window.height - @bottom_wall.height - paddle_height,
      width: wall_width,
      height: paddle_height,
      color: wall_color
    )
    @bottom_right_wall.collidable_mode = :block
    self.colliding_objects.push(@bottom_right_wall)
  end

  def set_paddles
    _x, y = window.center
    x = 50
    y -= @paddle_height / 2
    @paddle1 = Simple2DDemo::Paddle.new(
      x: x,
      y: y,
      height: paddle_height,
      width: paddle_width
    )
    @paddle1.color = paddle_color
    @paddle1.rate = paddle_rate
    @paddle1.controlled = true
    @paddle1.controller = :left
    @paddle1.player_number = 1

    self.moving_objects.push(@paddle1)
    self.colliding_objects.push(@paddle1)

    @paddle2 = Simple2DDemo::Paddle.new(
      x: window.width - x,
      y: y,
      height: paddle_height,
      width: paddle_width
    )
    @paddle2.color = paddle_color
    @paddle2.rate = paddle_rate
    @paddle2.controlled = true
    @paddle2.controller = :right
    @paddle2.player_number = 1

    self.moving_objects.push(@paddle2) # IMPROVE: use initialize
    self.colliding_objects.push(@paddle2)
  end

  def find_shuttle
    self.moving_objects.detect { |mo| mo.is_a?(Simple2DDemo::Shuttle) }
  end
end