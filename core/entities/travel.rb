# frozen_string_literal: true

module Core
  module Entities
    # Responsibility: Aggregate root representing a complete trip itinerary
    # Tracks ordered collection of segments (flights, hotels, trains)
    # Calculates final destination based on segment chain and associations in connections
    class Travel
      attr_reader :segments, :base

      def initialize(base:, segments: [])
        @base = base
        @segments = segments
      end

      def add_segment(segment)
        @segments << segment
      end

      def destination
        segments = @segments.select(&:transport?).sort_by(&:start_time)

        # INFO: Just in case there's no flights or trains is a local travel return base.
        return @base if segments.empty?

        travels = associate_connected_segments(segments)

        # INFO: for one way travels, destination is the last segment destination
        return travels.first.last.destination if travels.size == 1

        # INFO: destination should be the intermediate (or last, if there's just one) travel origin
        travels[travels.size / 2].first.origin
      end

      private

      # INFO: This method will try to calculate the stopovers and layovers and group them.
      def associate_connected_segments(segments)
        travels = []
        current_travel = [segments.first]
        segments = segments[1..]

        segments.each do |segment|
          previous_segment = current_travel.last
          if previous_segment.connection_to?(segment) && segment.destination != @base
            current_travel << segment
          else
            travels << current_travel
            current_travel = [segment]
          end
        end

        travels << current_travel unless current_travel.empty?

        travels
      end
    end
  end
end
