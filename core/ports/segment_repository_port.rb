# frozen_string_literal: true

# INFO: Any repository that returns segments should inherit from this one, to ensure it has the same interface

module Core
  module Ports
    module SegmentRepositoryPort
      def find_all
        raise NotImplementedError, 'Subclasses must implement find_all'
      end

      private

      def parse_datetime(date_str, time_str)
        date = Date.parse(date_str)
        time = Time.parse(time_str)
        DateTime.new(date.year, date.month, date.day, time.hour, time.min)
      end

      def parse_date(date_str)
        Date.parse(date_str)
      end
    end
  end
end
