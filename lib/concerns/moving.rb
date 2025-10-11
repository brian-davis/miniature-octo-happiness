# frozen_string_literal: true

# Add movement functionality to a Game subclass.
# Separate concern from DirectionalInput, this handles placing
# and tracking objects across the window, not handling keyboard input.
module Moving
  def self.included(base)
    attr_accessor :moving_update
    attr_reader :moving_objects
  end

  def initialize(*args)
    super(*args)

    @moving_objects = []
    @moving_update = method(:move_all)
  end

  def controlled_objects
    @controlled_objects ||= moving_objects.select { |mo| mo.controlled }
  end

  def remove_object(obj)
    obj.remove and # removes from display only
    self.moving_objects.delete(obj)
  end

  private

  # Animate motion across the window.
  # Called from main loop.
  # Simple movement, including "NPC" objects.
  def move_all
    self.moving_objects.each { |obj| obj.move! }
  end
end