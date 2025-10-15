module Simple2DDemo
  # The ping-pong ball (skee-ball puck) for Pong game.
  class Shuttle < Simple2DDemo::Npc
    def initialize(**args)
      super(**args)
      @type = :shuttle # DEBUG
    end
  end
end