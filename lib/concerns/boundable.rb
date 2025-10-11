# frozen_string_literal: true

module Boundable
  # assume Square
  alias_method :bounding_coordinates, def x_y_size
    [x, y, size]
  end
end