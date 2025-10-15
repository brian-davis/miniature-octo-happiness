# frozen_string_literal: true


module Simple2DDemo
  # Add movement functionality to a Game subclass.
  # Separate concern from DirectionalInput, this handles placing
  # and tracking objects across the window, not handling keyboard input.
  #
  # FIX: Avoid mutual dependencies between Moving, Colliding, Bounding
  module Moving
    # def self.included(base)
    # end

    attr_accessor :moving_update
    attr_reader :moving_objects

    def initialize(*args)
      super(*args)
      self.update_actions.push(:move_all)

      @moving_objects = []
      remove_observables.push(:moving_objects)
    end

    private

    # Animate motion across the window.
    # Called from main loop.
    # Simple movement, including "NPC" objects.
    def move_all
      self.moving_objects.each { |obj| obj.move! }
    end
  end
end