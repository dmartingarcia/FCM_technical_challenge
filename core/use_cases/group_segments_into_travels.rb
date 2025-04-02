# frozen_string_literal: true

module Core
  module UseCases
    # Responsibility: Aggregate root representing a complete trip itinerary
    # Calculate and join segments into travels
    # Enforces trip integrity rules
    class GroupSegmentsIntoTravels
      def initialize(segments, base)
        # INFO: this will prevent modify the original object and have a common segment list across all travels
        @segments = segments
        @base = base
      end

      def execute
        validate_input

        # This will duplicate the current segments to make the execution idempotent, as we're modifying the instance
        @current_segments = @segments.sort_by(&:start_time)

        travels = find_base_departures.map do |initial_segment|
          build_travel(initial_segment)
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
        departures = @current_segments.select { |segment| segment.transport? && segment.origin == @base }

        # INFO: but just in case there's a edge case scenario, we're going to process hotels if there's no transports
        if departures.empty?
          departures = @current_segments.select { |segment| segment.hotel? && segment.location == @base }
        end

        departures
      end

      def build_travel(current_segment)
        Core::Entities::Travel.new(base: @base).tap do |travel|
          # End trip if there's no other connections or hotel segments
          while current_segment
            travel.add_segment(@current_segments.delete(current_segment))

            # You're back in home mate! Ending your trip. Enjoy :)
            # This will prevent to continue traveling in case there's another trip that is on the same timeframe
            break if current_segment.destination == @base

            # First look for transport connections (less than 24 hours before arrival of the current segment)
            # Then look for hotels at current location if there's no transports
            current_segment = find_transport(current_segment) || find_hotel(current_segment)
          end
        end
      end

      def validate_input
        return unless @segments.empty?

        raise Core::Errors::EmptyItineraryError, 'No segments provided for grouping'
      end

      def find_hotel(current_segment)
        @current_segments.find do |segment|
          segment.hotel? &&
            segment.location == current_segment.destination &&
            segment.start_time <= current_segment.start_time
        end
      end

      def find_transport(current_segment)
        @current_segments.find do |segment|
          segment.transport? &&
            segment.origin == current_segment.destination &&
            segment.start_time <= current_segment.end_time.next_day
        end
      end
    end
  end
end
