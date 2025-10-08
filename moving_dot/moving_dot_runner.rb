# REFACTOR: standard bundled gem structure
require_relative "./moving_dot"
require "json"

config_json = JSON.load_file("moving_dot_config.json")
_flag, log_level = ARGV.detect { |arg| arg.match?(/--log-level/) }&.split("=")
moving_dot = MovingDot.new(config_json, log_level)
moving_dot.run

# $ ruby moving_dot_runner.rb --log-level=info