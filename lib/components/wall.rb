# A non-moving object which is interactive with the Pc or Npc objects.
# It affects their movements, but is itself unmoveable.
module Simple2DDemo
  # REFACTOR: Game concerns shouldn't inherit from shapes. Store shape as @var
  # FEATURE: moving walls, like something from Super Mario Bros castle levels.
  class Wall < Ruby2D::Rectangle
    include Pulseable
    include Collidable

    # Movable:collide_all duck-type
    # TODO: necessary?
    def moving?
      false
    end

    # A moving object (Cursor, Shuttle, Pc, etc.) triggers the collision in Colliding:collide_all
    # Static wall should bypass this logic
    # This affects wall placement (see e.g. Pong:set_walls): if walls are constantly checking :collides?,
    # and walls adjoin or overlap, debugger will flood output; so don't trigger debugger. Bypass allows
    # placing walls without worrying about overloading update loop.
    def collides?(other)
      super(other) unless stopped?
    end

    def stopped?
      # FEATURE: moving walls
      true
    end
  end
end
