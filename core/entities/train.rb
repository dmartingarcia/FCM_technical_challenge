# frozen_string_literal: true

module Core
  module Entities
    # Responsibility: Value object representing train journeys
    # Similar to Flight but with rail-specific metadata
    # Implements Core::Entities::Segment interface
    class Train
      include Core::Entities::Segment
      attr_reader :origin, :destination, :start_time, :end_time
    end
  end
end
