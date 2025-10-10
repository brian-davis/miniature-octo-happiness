# frozen_string_literal: true

require "ruby2d"
require "logger"

require_relative "decorators/ruby2d_decorator"

# Game class is an OOP container for using Ruby2d concerns
# in a standard way for making simple games à la Pong or Pacman.
# Avoid putting all Ruby2d calls and/or game logic in `main` context.
#
# example usage:
#   config_json = JSON.load_file("moving_dot_config.json")
#   moving_dot = Game.new(config_json)
#   moving_dot.run
class Game
  attr_reader :config, :logger, :window

  def initialize(config = {}, log_level = :warn)
    @window = Ruby2D::Window # singleton

    set_logger(log_level)
    configure(config)
    register_inputs()
  end

  def run
    run_info()
    window.show() # launch GUI app
  end

  private

  def set_logger(log_level)
    @logger = Logger.new(STDERR) # attr_reader :logger
    level_class = {
      "unknown" => Logger::UNKNOWN,
      "fatal"   => Logger::FATAL,
      "error"   => Logger::ERROR,
      "warn"    => Logger::WARN,
      "info"    => Logger::INFO,
      "debug"   => Logger::DEBUG
    }[log_level]
    logger.level = level_class || Logger::WARN
    logger.formatter = proc do |log_level, datetime, _progname, msg|
      t = datetime.strftime("%H:%M:%S:%4N")
      "[#{log_level}] #{t} :\t#{msg}\n"
    end
  end

  def configure(config_json)
    @config = config_json # attr_reader :config

    window.set(
      title:  window_title,
      width:  config["window_width"],
      height: config["window_hieght"]
    )

    logger.info "window title:    #{window_title}"
    logger.info "window width:    #{window_width}"
    logger.info "window height:   #{window_height}"
    logger.info "window center:   #{window.center}"
  end

  # Default window behaviors. Decorate in subclass.
  def register_inputs
    window.on :key_down do |event|
      logger.debug event
      case event.key
      when "q", "Q"
        exit()
      end
    end
  end

  # Display instructional message to user in main terminal window.
  def run_info
    STDOUT.puts
    STDOUT.puts(window_title)
    STDOUT.puts
    STDOUT.puts(config["run_info"]) # nil/empty OK

    return true
  end

  def window_width
    @window_width ||= window.get(:width)
  end

  def window_height
    @window_height ||= window.get(:height)
  end

  def window_title
    @window_title ||= config["window_title"]&.strip&.upcase
  end
end

