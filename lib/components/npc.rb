# Moving objects in Game window which are not under user control.
class Npc < Ruby2D::Square
  include Pulseable
  include Moveable
  include Collidable
end