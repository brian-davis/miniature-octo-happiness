# Moving objects in Game window which are under user control.
# AKA a "cursor"
class Pc < Ruby2D::Square
  include Pulseable
  include Moveable
  include Collidable
end