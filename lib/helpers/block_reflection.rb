# Used in Collidable. Extracted gnarly process to its own file.
class BlockReflection
  class << self
    def get(obj, blocker)
      return [nil, blocker.last_direction] if blocker.collidable_mode == :reflect

      ### get coordinates ###

      block_top_left, block_bottom_right = blocker.xy_coverage
      block_left   = block_top_left[0]
      block_right  = block_bottom_right[0]
      block_top    = block_top_left[1]
      block_bottom = block_bottom_right[1]
      block_x_center = ((block_left + block_right) / 2).round
      block_y_center = ((block_top + block_bottom) / 2).round

      $logger.debug { "block_left: #{block_left}" }
      $logger.debug { "block_right: #{block_right}" }
      $logger.debug { "block_top: #{block_top}" }
      $logger.debug { "block_bottom: #{block_bottom}" }
      $logger.debug { "block_x_center: #{block_x_center}" }
      $logger.debug { "block_y_center: #{block_y_center}" }

      obj_top_left, obj_bottom_right = obj.static_xy_coverage
      obj_left   = obj_top_left[0]
      obj_right  = obj_bottom_right[0]
      obj_x_center = ((obj_left + obj_right) / 2).round
      obj_top    = obj_top_left[1]
      obj_bottom = obj_bottom_right[1]
      obj_y_center = ((obj_top + obj_bottom) / 2).round

      $logger.debug { "obj_left: #{obj_left}" }
      $logger.debug { "obj_right: #{obj_right}" }
      $logger.debug { "obj_x_center: #{obj_x_center}" }
      $logger.debug { "obj_top: #{obj_top}" }
      $logger.debug { "obj_bottom: #{obj_bottom}" }
      $logger.debug { "obj_y_center: #{obj_y_center}" }

      ### get relative positions ###

      # Find general direction; is the obj up_left of the block?
      up_or_down = if obj_y_center < block_y_center
          :up
        elsif obj_y_center == block_y_center
          nil
        elsif obj_y_center > block_y_center
          :down
        end

      left_or_right = if obj_x_center < block_x_center
          :left
        elsif obj_x_center == block_x_center
          nil
        elsif obj_x_center > block_x_center
          :right
        end
      general_direction = [up_or_down,left_or_right].compact.join("_").to_sym
      $logger.debug { "general_direction: #{general_direction}" }

      ### Find edge ###

      edge = case general_direction
        when :up_left
          obj_bottom <= block_top ? :top_edge : :left_edge
        when :up
          :top_edge
        when :up_right
          obj_bottom <= block_top ? :top_edge : :right_edge
        when :left
          :left_edge
        when :right
          :right_edge
        when :down_left
          obj_top <= block_bottom ? :left_edge : :bottom_edge
        when :down
          :bottom_edge
        when :down_right
          obj_top <= block_bottom ? :right_edge : :bottom_edge
        end

      $logger.debug { "last_direction: #{obj.last_direction}; edge: #{edge}" }

      reflection = if blocker.stopped?
        # Static wall
        ### 12 possible angles: 3 angles (negative-straight-positive) * 4 edges
        casematcher = [obj.last_direction, edge]
        case casematcher
        in [:down, :top_edge]
          :up
        in [:down, _]
          nil
        in [:up, :bottom_edge]
          :down
        in [:up, _]
          nil
        in [:left, :right_edge]
          :right
        in [:left, _]
          nil
        in [:right, :left_edge]
          :left
        in [:right, _]
          nil
        in [:up_left, :right_edge]
          :up_right
        in [:up_left, :bottom_edge]
          :down_left
        in [:up_left, _]
          nil
        in [:up_right, :left_edge]
          :up_left
        in [:up_right, :bottom_edge]
          :down_right
        in [:up_right, _]
          nil
        in [:down_right, :left_edge]
          :down_left
        in [:down_right, :top_edge]
          :up_right
        in [:down_right, _]
          nil
        in [:down_left, :right_edge]
          :down_right
        in [:down_left, :top_edge]
          :up_left
        in [:down_left, nil]
          nil
        end
      else
        # Moving wall
        casematcher = [obj.last_direction, edge, blocker.last_direction]
        case casematcher
        in [:left, :top_edge, _]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :up_left
        in [:left, :bottom_edge, _]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :down_left
        in [:left, :right_edge, :down]
          :down_right
        in [:left, :right_edge, :up]
          :up_right
        in [:left, :left_edge, _]
          nil
        in [:right, :top_edge, _]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :up_right
        in [:right, :bottom_edge, _]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :down_right
        in [:right, :left_edge, :down]
          :down_left
        in [:right, :left_edge, :up]
          :up_left
        in [:right, :right_edge, _]
          nil
        in [:up_left, :right_edge, :up]
          :up_right
        in [:up_left, :right_edge, :down]
          :right
        in [:up_left, :bottom_edge, _]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :down_left
        in [:up_left, :bottom_edge, :down]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :down_left
        in [:up_left, :left_edge, _]
          nil
        in [:up_left, :top_edge, _]
          nil
        in [:up_right, :left_edge, :down]
          :left
        in [:up_right, :left_edge, :up]
          :up_left
        in [:up_right, :bottom_edge, :up]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :down_right
        in [:up_right, :bottom_edge, :down]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :down_right
        in [:up_right, :right_edge, _]
          nil
        in [:up_right, :top_edge, _]
          nil
        in [:down_right, :left_edge, :up]
          :left
        in [:down_right, :left_edge, :down]
          :down_left
        in [:down_right, :top_edge, :up]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :up_right
        in [:down_right, :top_edge, :down]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :up_right
        in [:down_right, :right_edge, _]
          nil
        in [:down_right, :bottom_edge, _]
          nil
        in [:down_left, :right_edge, :down]
          :down_right
        in [:down_left, :right_edge, :up]
          :right
        in [:down_left, :top_edge, :up]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :up_left
        in [:down_left, :top_edge, :down]
          # same up or down FEATURE: collide_physics or simple speed-adjust
          :up_left
        in [:down_left, :left_edge, _]
          nil
        in [:down_left, :bottom_edge, _]
          nil
        else
          nil
        end
      end
      if reflection.nil?
        $logger.debug{ "invalid reflection: #{casematcher}" }
        # raise "invalid reflection"
      end
      [edge, reflection]
    end
  end
end