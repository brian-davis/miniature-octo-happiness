# frozen_string_literal: true

module Colliding
  COLLIDING_MODES = [
    :collide_reflect,
    :collide_stop,
    :collide_eliminate
    # :collide_physics # FEATURE REQUEST
  ]

  # def self.included(base)
  # end

  attr_reader :colliding_update
  attr_accessor :colliding_mode

  def initialize(*args)
    super(*args)

    # REFACTOR:try to avoid hard dependencies
    unless self.class.ancestors.map(&:to_s).include?("Moving") &&
            self.class.ancestors.map(&:to_s).include?("Bounding") &&
            self.window # Game
      raise ArgumentError, "Colliding depends on Moving and Bounding"
    end
    @colliding_mode = COLLIDING_MODES.first # reset after init
    @colliding_update = method(:collide_all)
  end

  private

  # IMPROVE: add block objects here?
  def collision_candidates(obj)
    self.moving_objects.reject { |mo| mo.equal?(obj) } # Moving
  end

  def collide_all
    self.moving_objects.each do |obj|
      # IMPROVE: This algorithm is n! or similar
      collider = collision_candidates(obj).detect do |other|
        obj.collides?(other)
      end

      if collider
        logger.debug { "collision: #{obj.xy_coverage} + #{collider.xy_coverage}" }
        send(colliding_mode, obj, collider)
      end
    end
  end

  # FEATURE REQUEST: explosion animation
  def collide_eliminate(obj1, obj2)
    remove_object(obj1)
    remove_object(obj2)
  end

  # clumping effect
  def collide_stop(obj1, obj2)
    obj1.collide_stop!(obj2)
  end

  # simple bounce effect
  def collide_reflect(obj1, obj2)
    logger.debug { "collide_reflect" }
    obj1.collide_reflect!(obj2)
  end

  # # FEATURE REQUEST: pool-table logic, account for
  #     force, angle, mass, assymmetric speeds.
  # def collide_physics
  # end
end