module Core
  module Entities
    module Segment
      # INFO: I prefer to use composition over inheritance as
      # we can extend the logic of any entity independently of the previous assigned logic.
      def hotel?
        is_a?(Core::Entities::Hotel)
      end

      def transport?
        [Core::Entities::Flight, Core::Entities::Train].any? { |c| is_a?(c) }
      end

      def connection_to?(segment)
        segment_destination = if segment.transport?
                                segment.origin
                              else
                                segment.location
                              end

        object_destination = if transport?
                               destination
                             else
                               location
                             end

        # Check connection conditions:
        # (a) The new segment's departure is within 24 hours after previous arrival.
        # (b) The new segment's origin matches the previous segment's destination.
        segment.start_time <= end_time.next_day && segment_destination == object_destination
      end
    end
  end
end
