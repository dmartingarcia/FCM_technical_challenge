# frozen_string_literal: true

module Core
  module Entities
    class Hotel
      include Core::Entities::Segment
      attr_reader :location, :start_time, :end_time

      def initialize(location:, start_time:, end_time:)
        @location = location
        @start_time = start_time
        @end_time = end_time
      end
    end
  end
end
