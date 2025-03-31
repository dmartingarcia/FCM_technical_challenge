# frozen_string_literal: true

module Core
  module Entities
    class Hotel
      attr_reader :location, :start_time, :end_time

      def initialize(location:, start_time:, end_time:)
        @location = location
        @start_time = start_time
        @end_time = end_time
      end
    end
  end
end
