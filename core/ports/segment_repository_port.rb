# frozen_string_literal: true

require 'time'

# INFO: Any repository that returns segments should inherit from this one,
# to ensure it has the same interface, it also provides some helper functions

module Core
  module Ports
    # Responsibility: Define input contract for data sources
    # Methods:
    #  - find_all: Returns chronologically ordered segments from the source
    module SegmentRepositoryPort
      def find_all; end

      private

      def parse_datetime(date_str, time_str)
        # INFO: Checking the date and time before creating the datetime.
        date = Date.parse(date_str)
        time = Time.parse(time_str)
        DateTime.new(date.year, date.month, date.day, time.hour, time.min)
      rescue ArgumentError => e
        raise Core::Errors::InvalidDateError, "Invalid date #{date_str} - #{e.backtrace}"
      end

      def parse_date(date_str)
        Date.parse(date_str)
      rescue ArgumentError => e
        raise Core::Errors::InvalidDateError, "Invalid date #{date_str} - #{e.backtrace}"
      end
    end
  end
end
