# frozen_string_literal: true

module Simple2DDemo
  # Add trailing functionality to a Game subclass.
  module Trailing
    attr_reader :enable_trail

    def initialize(*args)
      super(*args)
      @enable_trail = config["enable_trail"] # Game
      logger.info {"enable_trail: #{@enable_trail}"}
    end
  end
end
