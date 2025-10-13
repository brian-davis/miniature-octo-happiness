# Moving objects in Game window which are not under user control.
module Simple2DDemo
  class Npc < Ruby2D::Square
    include Pulseable
    include Moveable
    include Collidable
  end
end