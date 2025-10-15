module Simple2DDemo
  # Moving objects in Game window which are not under user control.
  # IMPROVE: don't inherit from Square
  class Npc < Ruby2D::Square
    include Pulseable
    include Moveable
    include Collidable

    attr_accessor :type

    def initialize(**args)
      @type = args.delete(:type)
      super(**args)
    end
  end
end