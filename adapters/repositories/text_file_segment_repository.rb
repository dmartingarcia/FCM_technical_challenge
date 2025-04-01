# frozen_string_literal: true

require 'date'

module Adapters
  module Repositories
    class TextFileSegmentRepository
      include Core::Ports::SegmentRepositoryPort

      def initialize(file_path, logger_instance: Adapters::Loggers::StdoutLogger.new)
        @file_path = file_path
        @logger_instance = logger_instance
      end

      def find_all_sorted
        file_content = read_file_content
        process_segment_reservations(file_content)
      end

      private

      def read_file_content
        File.readlines(@file_path)
      rescue SystemCallError => e
        raise Core::Errors::FileReadError, "File error: #{e.message}"
      end

      def process_segment_reservations(lines)
        lines.filter { |line| line.start_with?('SEGMENT: ') }
             .filter_map { |line| process_segment_line(line) }
             .sort_by(&:start_time)
      end

      def process_segment_line(line)
        raw_segment = line.chomp.sub('SEGMENT: ', '')
        parse_segment(raw_segment)
      rescue Core::Errors::InvalidSegmentError, Core::Errors::InvalidDateError => e
        log_parse_error(e.message)
        nil
      end

      def parse_segment(line)
        case line
        when /^Flight/ then create_transport(line, Core::Entities::Flight)
        when /^Train/ then create_transport(line, Core::Entities::Train)
        when /^Hotel/ then create_hotel(line, Core::Entities::Hotel)
        else
          raise Core::Errors::InvalidSegmentError, "Unknown segment type: #{line}"
        end
      end

      def create_transport(line, klass)
        match = line.match(/(\w+) (\w{3}) (\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}) -> (\w{3}) (\d{2}:\d{2})/)

        raise Core::Errors::InvalidSegmentError, "Invalid transport format: #{line}" unless match

        origin = match[2]
        destination = match[5]
        departure = parse_datetime(match[3], match[4])
        arrival = parse_datetime(match[3], match[6])

        arrival = arrival.next_day if next_day?(departure, arrival)

        transport = klass.new(
          origin: origin,
          destination: destination,
          start_time: departure,
          end_time: arrival
        )

        validate_start_and_end_date(transport)

        transport
      rescue ArgumentError => e
        raise Core::Errors::InvalidDateError, "Invalid date in: #{line} - #{e.backtrace}"
      end

      def next_day?(departure, arrival)
        arrival < departure
      end

      def validate_start_and_end_date(segment)
        raise Core::Errors::InvalidDateError, 'start_time >  end_time' if segment.start_time > segment.end_time
      end

      def create_hotel(line, klass)
        match = line.match(/Hotel (\w{3}) (\d{4}-\d{2}-\d{2}) -> (\d{4}-\d{2}-\d{2})/)
        raise Core::Errors::InvalidSegmentError, "Invalid hotel format: #{line}" unless match

        location = match[1]

        check_in = parse_date(match[2])
        check_out = parse_date(match[3])

        hotel = klass.new(
          location: location,
          start_time: check_in,
          end_time: check_out
        )
        validate_start_and_end_date(hotel)

        hotel
      rescue ArgumentError => e
        raise Core::Errors::InvalidDateError, "Invalid date in: #{line} - #{e.backtrace[..2]}"
      end

      def log_parse_error(message)
        @logger_instance.log_error "[Parse Error] #{message}"
      end
    end
  end
end
