# frozen_string_literal: true

# Demonstrate basic Ruby2D operation. A single cursor object,
# a dot, with a visual pulse effect which can be moved around the window
# using directional keys, with configurable behavior at window borders.
# A wall object in in the middle of the map, blocking some movements.
class Tiles < Simple2DDemo::Game
  include Simple2DDemo::Pulsing

  DEFAULT_TILE_SIZE = 40
  DEFAULT_PULSE_RATE = 10
  DEFAULT_STRIPE_PATTERN = "vertical"
  STRIPE_PATTERNS = ["vertical", "horizontal", "diagonal", "scramble"]

  attr_reader :tile_size, :pulse_rate, :stripe_pattern

  def initialize(*args)
    super(*args)
    @tile_size = config["tile_size"] || DEFAULT_TILE_SIZE
    @pulse_rate = config["pulse_rate"] || DEFAULT_PULSE_RATE

    @stripe_pattern = config["stripe_pattern"] || DEFAULT_STRIPE_PATTERN
    unless STRIPE_PATTERNS.include?(@stripe_pattern)
      raise ArgumentError, "invalid stripe_pattern"
    end

    set_tiles
  end

  private

  def set_tiles
    columns, column_remainder = window_width.divmod(tile_size)
    column_gutter = column_remainder / 2

    rows, row_remainder = window_height.divmod(tile_size)
    row_gutter = row_remainder / 2

    pulse_values = Simple2DDemo::Gradients.random_color_gradient

    (0...rows).each do |row|
      (0...columns).each do |column|
        tile = Simple2DDemo::Background.new(
          x: column_gutter + (column * tile_size),
          y: row_gutter + (row * tile_size),
          size: tile_size
        )
        tile.pulse_values = pulse_values
        tile.pulse_rate = pulse_rate

        cycle_color = ->(tile) {
          tile.color = tile.pulse_cycle.next
        }

        case stripe_pattern
        when "vertical"
          column.times { cycle_color.call(tile) }
        when "diagonal"
          row.times    { cycle_color.call(tile) }
          column.times { cycle_color.call(tile) }
        when "horizontal"
          row.times    { cycle_color.call(tile) }
        when "scramble"
          rand(pulse_values.size).to_i.times { cycle_color.call(tile) }
        end

        pulsing_objects.push(tile)
      end
    end
  end
end