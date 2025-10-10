# Extend Array class with helper methods
class Array
  # Convert an array into a cycle object which will not
  # make a jarring leap from last place to first place,
  # or have a doubling effect at the extremes.
  # e.g.
  # [1,2,3,4] => (1,2,3,4,3,2,1,2,3,4,3,2 ...)
  def gradient_cycle
    return nil if empty?
    up_half = self.dup
    down_half = up_half[1...-1].reverse
    (up_half + down_half).cycle
  end
end

