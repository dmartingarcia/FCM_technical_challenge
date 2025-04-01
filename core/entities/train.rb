# frozen_string_literal: true

module Core
  module Entities
    class Train
      include Core::Entities::Segment
      attr_reader :origin, :destination, :start_time, :end_time

      def initialize(origin:, destination:, start_time:, end_time:)
        @origin = origin
        @destination = destination
        @start_time = start_time
        @end_time = end_time
      end
    end
  end
end
