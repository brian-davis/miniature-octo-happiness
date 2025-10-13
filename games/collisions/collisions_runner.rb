# frozen_string_literal: true

require "json"

require_relative "../../lib/game"

self_filename = __FILE__.split('/').last.split('.').first
klass_filename = self_filename.match(/\A(.+)_runner/)[1]
require_relative "./#{klass_filename}"
config_filename = "#{klass_filename}_config.json"
config_filepath = File.expand_path(File.join(__dir__, config_filename))
config_json = JSON.load_file(config_filepath) if File.exist?(config_filepath)
_flag, log_level = ARGV.detect { |arg| arg.match?(/--log-level/) }&.split("=")
args = [config_json, log_level].compact

collisions = Collisions.new(*args)
collisions.run

# $ ruby collisions_runner.rb --log-level=info