# A non-moving colored point which is drawn on the window, which is not interactive.
# Use for artistic purposes.
module Simple2DDemo
  class Background < Ruby2D::Square
    include Pulseable
  end
end