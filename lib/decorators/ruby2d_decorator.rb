module Ruby2D
  class Window
    def self.random_point
      [rand(0...get(:width)), rand(0...get(:height))]
    end
  end
end

