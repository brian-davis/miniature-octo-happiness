# frozen_string_literal: true

require_relative "components/meteor"

# Demo for radiant meteor shower.
class Radiant < Simple2DDemo::Game
  # include Simple2DDemo::Pulsing

  # Defaults
  DOT_SIZE             = 4
  METEOR_SPAWN_RATE    = 20
  METEOR_COLOR         = "white"

  attr_reader :origin,
              :meteor_spawn_rate, :meteor_travel_rate, :meteor_color,
              :meteor_size
  attr_accessor :meteors, :meteor_trails

  def initialize(*args)
    super(*args)
    @meteors = []
    @origin = window.center # /decorators

    @meteor_size        = config["meteor_size"]        || DOT_SIZE
    @meteor_spawn_rate  = config["meteor_spawn_rate"]  || METEOR_SPAWN_RATE
    @meteor_travel_rate = config["meteor_travel_rate"] || METEOR_TRAVEL_RATE
    @meteor_color       = config["meteor_color"]       || METEOR_COLOR

    self.update_actions.push(:spawn_meteor)
    self.update_actions.push(:animate_meteor)
    self.remove_observables.push(:meteors)
  end

  private

  def spawn_meteor
    if meter?(meteor_spawn_rate)
      particle = Simple2DDemo::Meteor.new(
        x:     origin[0],
        y:     origin[1],
        size:  meteor_size,
        color: meteor_color,
        velocity: rand(1..meteor_travel_rate),
        randomize: true
      )

      self.meteors.push(particle)
    end
  end

  # REFACTOR: this duplicates Bounding
  BOUND = 100
  def out_of_bounds?(e)
    e.x < BOUND || e.x > (window_width - BOUND) ||
    e.y < BOUND || e.y > (window_height - BOUND)
  end

  def animate_meteor
    # if meter?(meteor_travel_rate)
      self.meteors.each { |e| e.update! }
      self.meteors.each { |e| remove_object(e) if out_of_bounds?(e) }
    # end
  end
end