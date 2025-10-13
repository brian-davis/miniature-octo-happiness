# frozen_string_literal: true

# $ ruby game_runner.rb star_field --log-level=info
VALID_SUB_RUNNERS = ["collisions", "moving_dot", "multiple_moving_dots", "obstacle", "star_field"]
sub_runner_dir = ARGV[0]
message = "#{sub_runner_dir} not found. Valid options: #{VALID_SUB_RUNNERS.join(', ')}"
sub_runner = "#{sub_runner_dir}_runner.rb"
sub_runner_filepath = File.expand_path(File.join(__dir__, "games", sub_runner_dir, sub_runner))
load(sub_runner_filepath) # ARGV passed thru