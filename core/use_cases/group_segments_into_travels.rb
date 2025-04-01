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

      # rubocop:disable Metrics/MethodLength
      # Will be better to have a longer method that be forced to split the logic
      def build_travel(initial_segment, segments)
        travel = Core::Entities::Travel.new(base: @base, segments: [initial_segment])
        segments.delete(initial_segment)

        current_location = initial_segment.destination
        current_end_time = initial_segment.end_time

        loop do
          # First look for transport connections (less than 24 hours before arrival of the current segment)
          transport = find_next_transport(current_location, current_end_time, segments)
          if transport
            travel.add_segment(transport)
            segments.delete(transport)
            current_location = transport.destination
            current_end_time = transport.end_time
            next
          end

          # Then look for hotels at current location if there's no connections
          hotel = find_hotel(current_location, current_end_time, segments)
          if hotel
            travel.add_segment(hotel)
            segments.delete(hotel)
            current_end_time = hotel.end_time
            next
          end

          # End trip if we return to base or there's no other connections or hotel segments
          break if current_location == @base || (hotel.nil? && transport.nil?)
        end

        travel
      end
      # rubocop:enable Metrics/MethodLength

      def validate_input!
        return unless @segments.empty?

        raise Core::Errors::EmptyItineraryError, 'No segments provided for grouping'
      end

      def find_hotel(location, max_start_time, segments)
        segments.find do |segment|
          segment.hotel? &&
            segment.location == location &&
            segment.start_time <= max_start_time
        end
      end

      def find_next_transport(current_location, last_end_time, segments)
        segments.find do |segment|
          segment.transport? &&
            segment.origin == current_location &&
            segment.start_time <= last_end_time.next_day
        end
      end
    end
  end
end
