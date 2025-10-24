# frozen_string_literal: true

# Based on Chapter 13 of book Impractical Python Projects, Lee Vaughan, No Starch Press.
# Original [Ruby port](https://github.com/brian-davis/didactic-octo-winner/blob/main/ch13/tvashtar.rb)

# REFACTOR: Use this game-specific component pattern more.
require_relative("components/particle")

class Eruption < Simple2DDemo::Game
  # include Simple2DDemo::Pulsing
  include Simple2DDemo::Moving

  BACKGROUND_IMAGE = "images/tvashtar_plume.png"
  DEFAULT_DOT_SIZE = 4
  GRAVITY = 0.5
  PARTICLE_SPAWN_RATE = 20
  PARTICLE_MOVEMENT_RATE = 2

  attr_reader :background, :origin, :dot_size, :gravity, :particle_spawn_rate, :particle_movement_rate
  attr_accessor :particles, :particle_trails

  def initialize(*args)
    super(*args)
    @background = Image.new(File.expand_path(File.join(__dir__, BACKGROUND_IMAGE)))
    @origin = [320, 300]
    @gravity = GRAVITY
    @dot_size = config["dot_size"] || DEFAULT_DOT_SIZE
    @particles = []
    @particle_spawn_rate = config["particle_spawn_rate"] || PARTICLE_SPAWN_RATE
    @particle_movement_rate = config["particle_movement_rate"] || PARTICLE_MOVEMENT_RATE

    self.update_actions.push(:spawn_particle)
    self.update_actions.push(:animate_particle)
    self.remove_observables.push(:particles)
  end

  private

  def spawn_particle
    if meter?(self.particle_spawn_rate)
      particle = Simple2DDemo::Particle.new(
        x: origin[0],
        y: origin[1],
        size: dot_size,
        gravity: self.gravity,
        color: 'white' # default, overwrite
      )
      self.particles.push(particle)
    end
  end

  # REFACTOR: this duplicates Bounding
  def out_of_bounds?(e)
    e.x < 0 || e.x > window_width || e.y < 0 ||
    e.y > origin[1] # the planet surface
  end

  def animate_particle
    return unless meter?(self.particle_movement_rate)
    self.particles.each { |e| e.update! }
    self.particles.each { |e| remove_object(e) if out_of_bounds?(e) }
  end
end