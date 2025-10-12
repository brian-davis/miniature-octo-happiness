module Ruby2D
  class Window
    # Window class object is used directly, not instantiated
    class << self
      def random_point(edge = 0)
        x = get(:width) - edge
        y = get(:height) - edge
        [rand(0...x), rand(0...y)]
      end

      def center
        @center ||= [(get(:width) / 2), (get(:height) / 2)]
      end
    end
  end
end

