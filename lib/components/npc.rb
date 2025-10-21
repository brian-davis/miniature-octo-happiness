module Simple2DDemo
  # Moving objects in Game window which are not under user control.
  class Npc < Ruby2D::Square # IMPROVE: don't inherit from Square
    include Pulseable
    include Moveable
    include Collidable

    def initialize(**args)
      super(**args)
    end
  end
end