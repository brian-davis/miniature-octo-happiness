module Ruby2D
  class Window
    # Window class object is used directly, not instantiated
    class << self
      def random_point
        [rand(0...get(:width)), rand(0...get(:height))]
      end

      def center
        @center ||= [(get(:width) / 2), (get(:height) / 2)]
      end
    end
  end
end

