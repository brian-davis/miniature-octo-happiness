# frozen_string_literal: true

module Simple2DDemo
  # Include this in games. Don't include this in Screensavers.
  module Ending
    # def self.included(base)
    # end

    # attr_reader :ending_update
    attr_accessor :game_enders

    def initialize(*args)
      super(*args)
      self.game_enders = []
      self.remove_observables.push(:game_enders) # Game
      self.update_actions.push(:end_game?)
    end

    private

    def end_game?
      end_game! if game_over?
    end

    def game_over?
      game_enders.length == 0 # .empty?
    end

    def end_game!
      STDOUT.puts "GAME OVER"
      exit(0)
    end
  end
end
