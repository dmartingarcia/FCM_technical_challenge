# frozen_string_literal: true

module Core
  module Entities
    # Responsibility: Value object representing flight segments
    # Stores origin, destination, departure/arrival times
    # Implements Core::Entities::Segment interface
    class Flight
      include Core::Entities::Segment
      attr_reader :origin, :destination, :start_time, :end_time
    end
  end
end
