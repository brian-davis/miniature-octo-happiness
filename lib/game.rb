# frozen_string_literal: true

require "ruby2d"
require "logger"

### Master requirements. Assume everything is always loaded. ###
# IMPROVE

["decorators", "helpers", "concerns", "components"].each do |subdir|
  Dir.glob(File.join(__dir__, subdir,'*.rb')).each { |file| require file }
end

### Module ###

module Simple2DDemo
  # Game class is an OOP container for using Ruby2d concerns
  # in a standard way for making simple games à la Pong or Pacman.
  # Avoid putting all Ruby2d calls and/or game logic in `main` context.
  #
  # example usage:
  #   config_json = JSON.load_file("moving_dot_config.json")
  #   moving_dot = Game.new(config_json)
  #   moving_dot.run
  class Game
    # no Integer::MAX in newer rubies, but try to prevent memory overflow
    # https://stackoverflow.com/a/60828820
    # https://stackoverflow.com/a/43040560
    MAX_TICK = 2 ** 63 - 1 # 60 cycles per second

    attr_reader   :config, :window
    attr_accessor :update_actions, :remove_observables, :master_tick

    def initialize(config = {}, log_level = :warn)
      @window = Ruby2D::Window # singleton
      @update_actions = []
      @remove_observables = []
      @master_tick = 0

      set_logger(log_level)
      configure(config)
      register_inputs()

      set_update
    end

    def run
      run_info()
      window.show() # launch GUI app
    end

    def logger
      $logger
    end

    def remove_object(obj)
      logger.debug { "remove_object: #{obj}" }
      obj.remove # removes from display only
      remove_observables.each do |attr|
        send(attr).delete(obj) # removes from Game memory
      end
    end

    def set_logger(log_level)
      $logger = Logger.new(STDERR)
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
        height: config["window_height"]
      )

      logger.info { "window title:    #{window_title}" }
      logger.info { "window width:    #{window_width}" }
      logger.info { "window height:   #{window_height}" }
      logger.info { "window center:   #{window.center}" }
    end

    # Default window behaviors. Decorate in subclass.
    def register_inputs
      window.on :key_down do |event|
        logger.debug { event }
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

    def set_update
      window.update do
        self.update_actions.each { |method_name| self.send(method_name) }
        tick!
      end
    end

    private

    # Components hook into :master_tick to control rate of updates.
    def tick!
      self.master_tick = 0 if self.master_tick >= MAX_TICK
      self.master_tick += 1
    end

    # REFACTOR: use this helper in all :update_actions
    def meter?(n)
      master_tick % n  == 0
    end
  end
end