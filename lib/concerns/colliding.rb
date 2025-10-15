# frozen_string_literal: true

module Simple2DDemo
  module Colliding
    # def self.included(base)
    # end

    attr_reader :colliding_update
    attr_accessor :colliding_objects

    def initialize(*args)
      super(*args)
      self.update_actions.push(:collide_all)
      self.colliding_objects = []
      remove_observables.push(:colliding_objects)
    end

    private

    def collision_candidates(obj)
      # self.colliding_objects.reject { |mo| mo.equal?(obj) }
      self.colliding_objects - [obj]
    end

    def collide_all
      self.colliding_objects.each do |obj|
        # IMPROVE
        collider = collision_candidates(obj).detect do |other|
          obj.collides?(other)
        end

        if collider
          logger.debug { "collision: #{obj.xy_coverage} + #{collider.xy_coverage}" }
          pre_obj = obj.dup
          obj.collide!(collider) # obj state updated (not other)
          collider.collide!(pre_obj) # other state updated, use initial obj state
        end
      end
    end
  end
end
