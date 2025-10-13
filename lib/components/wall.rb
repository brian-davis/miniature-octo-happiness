# A non-moving object which is interactive with the Pc or Npc objects.
# It affects their movements, but is itself unmoveable.
module Simple2DDemo
  class Wall < Ruby2D::Rectangle
    include Pulseable
    include Blockable
  end
end
