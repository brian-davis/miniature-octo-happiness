
module Simple2DDemo
  module SquarePosition
    class << self
      # Do two squares overlap?
      def overlap?(a, b)
        a_x_range, a_y_range = square_ranges(a)
        b_x_range, b_y_range = square_ranges(b)

        a_x_range.overlap?(b_x_range) &&
        a_y_range.overlap?(b_y_range)
      end

      private

      # a =  [
      #   [320, 240], # top_left
      #   [330, 250]  # bottom_right
      # ]
      # xr, yr = square_ranges(a)
      # puts xr == (320..330) && yr == (240..250)
      def square_ranges(arr)
        x_r = arr[0][0]..arr[1][0]
        y_r = arr[0][1]..arr[1][1]
        [x_r, y_r]
      end # def
    end # class
  end # module
end # module
