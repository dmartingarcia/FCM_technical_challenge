# frozen_string_literal: true

module Core
  module UseCases
    class GroupSegmentsIntoTravels
      def initialize(segments, base)
        @segments = segments
        @base = base
      end

      def execute
        validate_input!

        # INFO: this will prevent modify the original object and have a common segment list across all travels
        segments = @segments.dup.sort_by(&:start_time)

        travels = find_base_departures.map do |initial_segment|
          build_travel(initial_segment, segments)
        end

        sort_travels_by_date(travels)
      end

      private

      def sort_travels_by_date(travels)
        travels.sort_by { |travel| travel.segments.first.start_time }
      end

      def find_base_departures
        # INFO: it will get the first segment that starts on the base
        # INFO: It must be a transport, there's no reason to start a travel on a hotel
        @segments.select { |segment| segment.transport? && segment.origin == @base }
      end

      def build_travel(current_segment, segments)
        Core::Entities::Travel.new(base: @base, segments: [current_segment]).tap do |travel|
          segments.delete(current_segment)
          # End trip if we return to base or there's no other connections or hotel segments
          while !current_segment.nil? && segment_destination(current_segment) != @base
            # First look for transport connections (less than 24 hours before arrival of the current segment)
            # Then look for hotels at current location if there's no transports
            current_segment = find_next_transport(current_segment, segments) || find_hotel(current_segment, segments)

            travel.add_segment(current_segment) && segments.delete(current_segment) if current_segment
          end
        end
      end

      def validate_input!
        return unless @segments.empty?

        raise Core::Errors::EmptyItineraryError, 'No segments provided for grouping'
      end

      def segment_destination(segment)
        if segment.is_a?(Core::Entities::Hotel)
          segment.location
        else
          segment.destination
        end
      end

      def find_hotel(current_segment, segments)
        segments.find do |segment|
          segment.hotel? &&
            segment.location == segment_destination(current_segment) &&
            segment.start_time <= current_segment.start_time
        end
      end

      def find_next_transport(current_segment, segments)
        segments.find do |segment|
          segment.transport? &&
            segment.origin == segment_destination(current_segment) &&
            segment.start_time <= current_segment.end_time.next_day
        end
      end
    end
  end
end
