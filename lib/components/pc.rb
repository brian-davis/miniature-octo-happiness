# Moving objects in Game window which are under user control.
# AKA a "cursor"
module Simple2DDemo
  # IMPROVE: don't depend on square
  class Pc < Ruby2D::Square
    include Pulseable
    include Moveable
    include Collidable

    attr_accessor :player_number
  end
end