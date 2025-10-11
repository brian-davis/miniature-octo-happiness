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


# Easily built color gradient array values to feed into Pulseable
module Gradients
  # https://htmlcolorcodes.com/
  COMMON_COLOR_CODES = {
    "white"   => "#ffffff",
    "silver"  => "#c0c0c0",
    "gray"    => "#808080",
    "black"   => "#000000",
    "red"     => "#ff0000",
    "maroon"  => "#800000",
    "yellow"  => "#ffff00",
    "olive"   => "#808000",
    "lime"    => "#00ff00",
    "green"   => "#008000",
    "aqua"    => "#00ffff",
    "teal"    => "#008080",
    "blue"    => "#0000ff",
    "navy"    => "#000080",
    "fuchsia" => "#ff00ff",
    "purple"  => "#800080"
  }

  class << self
    # >> Gradiens.int_gradient(20, 5,4)
    # => [20, 15, 10, 5]
    # >> Gradiens.int_gradient(10, 100)
    # => [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    def int_gradient(a, b, n = 10)
      a, b = a.to_i, b.to_i
      is_reverse = a > b

      # kludge
      return [a] * n if a == b

      a, b = [a, b].minmax
      step_size = (b - a) / (n - 1)
      inermediate_range = ((a + step_size)..(b - step_size))
      intermediate = inermediate_range.step(step_size).to_a

      # kludge e.g. Gradiens.int_gradient(5, 20,9)
      # step_size is 1, get too-long result
      until intermediate.length <= n - 2
        intermediate.delete_at(rand(intermediate.length))
      end
      gradient = [a, *intermediate, b]
      is_reverse ? gradient.reverse : gradient
    rescue
      [a, b]
    end

    # naive approach
    def hex_gradient(hex_a, hex_b, size = 10)
      a_int = hex_a.sub("#", "").to_i(16)
      b_int = hex_b.sub("#", "").to_i(16)
      gradient = int_gradient(a_int, b_int, size)
      hexstr = n.to_s(16)[0...6].rjust(6, "0")
      gradient.map { |n| "#" + hexstr }
    end

    # 3-color split approach.
    def color_hex_gradient(color_a, color_b, size = 10)
      color_a, color_b = color_a.downcase, color_b.downcase
      to_i16 = -> (str) {
        str.sub("#", "").scan(/[0-9a-f]{2}/)
           .map { |hex| hex.to_i(16) } # 0..255
      }

      to_hex_gradient = -> (a, b, i) {
        int_gradient(a, b, i).map { |n| n.to_s(16).rjust(2, "0") }
      }

      r_a, g_a, b_a = to_i16.(color_a)
      r_b, g_b, b_b = to_i16.(color_b)

      # puts "r_a: #{r_a.inspect}"
      # puts "g_a: #{g_a.inspect}"
      # puts "b_a: #{b_a.inspect}"
      # puts
      # puts "r_b: #{r_b.inspect}"
      # puts "g_b: #{g_b.inspect}"
      # puts "b_b: #{b_b.inspect}"
      # puts

      r_grad = to_hex_gradient.(r_a, r_b, size)
      g_grad = to_hex_gradient.(g_a, g_b, size)
      b_grad = to_hex_gradient.(b_a, b_b, size)

      # puts "r_grad: #{r_grad.inspect}"
      # puts "g_grad: #{g_grad.inspect}"
      # puts "b_grad: #{b_grad.inspect}"
      # puts

      r_grad.zip(g_grad, b_grad).map { |hex_tuples| "#" + hex_tuples.join  }
    end

    def simple_color_gradient(color_name_a, color_name_b, size = 10)
      aval = COMMON_COLOR_CODES[color_name_a] || COMMON_COLOR_CODES["black"]
      bval = COMMON_COLOR_CODES[color_name_b] || COMMON_COLOR_CODES["white"]
      color_hex_gradient(aval, bval, size)
    end

    def random_color_gradient(include_black = false, size = 10)
      options = COMMON_COLOR_CODES.dup
      options.delete("black") unless include_black
      aval, bval = options.values.sample(2)
      color_hex_gradient(aval, bval, size)
    end

    def black_white
      @black_white ||= simple_color_gradient("black", "white", 16)
    end
  end
end