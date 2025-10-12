# frozen_string_literal: true

# Build obstacle blocks into the map.
module Blockable
  BLOCKING_MODES = [:block_reflect, :block_stop, :block_eliminate]

  attr_accessor :block, :blocking_mode

  def initialize(**args)
    super(**args)
    @blocking_mode = BLOCKING_MODES.first # default, reset after init
  end

  # The window-coordinates real-estate for the object
  # assume Rectangle
  # duck-typing, see collidable.rb
  def xy_coverage
    [
      [x, y], # top-left corner
      [(x + width), (y + height)], # bottom-right corner
    ]
  end
end