# frozen_string_literal: true

require 'date'

module Adapters
  module Repositories
    # Responsibility: Input data handling
    # Parses text file into domain entities
    # Validates segment format and chronology
    # Implements SegmentRepositoryPort interface
    class TextFileSegmentRepository
      include Core::Ports::SegmentRepositoryPort

      def initialize(file_path, logger_instance: Adapters::Loggers::StdoutLogger.new)
        @file_path = file_path
        @logger_instance = logger_instance
      end

      def find_all
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
        lines.filter { |line| line.start_with?('SEGMENT: ') }  # Get just the segment lines
             .filter_map { |line| process_segment_line(line) } # map them except nils (succesfully processed)
             .sort_by(&:start_time)
      end

      def process_segment_line(line)
        raw_segment = line.chomp.sub('SEGMENT: ', '')

        parse_segment(raw_segment).tap(&:validate_start_and_end_date)
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

        origin, date, departure_time, destination, arrival_time = match.to_a[2..]

        departure = parse_datetime(date, departure_time)
        arrival = parse_datetime(date, arrival_time)

        arrival = arrival.next_day if next_day?(departure, arrival)

        klass.new(
          origin: origin,
          destination: destination,
          start_time: departure,
          end_time: arrival
        )
      end

      def create_hotel(line, klass)
        match = line.match(/Hotel (\w{3}) (\d{4}-\d{2}-\d{2}) -> (\d{4}-\d{2}-\d{2})/)
        raise Core::Errors::InvalidSegmentError, "Invalid hotel format: #{line}" unless match

        location, check_in, check_out = match.to_a[1..]

        klass.new(
          location: location,
          start_time: parse_date(check_in),
          end_time: parse_date(check_out)
        )
      end

      def next_day?(departure, arrival)
        arrival < departure
      end

      def log_parse_error(message)
        @logger_instance.log_error "[Parse Error] #{message}"
      end
    end
  end
end
