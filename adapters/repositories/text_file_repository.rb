# frozen_string_literal: true

require 'date'
require_relative '../../core/entities/flight'
require_relative '../../core/entities/hotel'
require_relative '../../core/entities/train'
require_relative '../../core/ports/segment_repository_port'
require_relative '../loggers/stdout_logger'

module Adapters
  module Repositories
    class TextFileRepository
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
        raise Core::FileReadError, "File error: #{e.message}"
      end

      def process_segment_reservations(lines)
        lines.filter { |line| line.start_with?('SEGMENT: ') }
             .filter_map { |line| process_segment_line(line) }
             .sort_by(&:start_time)
      end

      def process_segment_line(line)
        raw_segment = line.chomp.sub('SEGMENT: ', '')
        parse_segment(raw_segment)
      rescue Core::InvalidSegmentError, Core::InvalidDateError => e
        log_parse_error(e.message)
        nil
      end

      def parse_segment(line)
        case line
        when /^Flight/ then create_transport(line, Core::Entities::Flight)
        when /^Train/ then create_transport(line, Core::Entities::Train)
        when /^Hotel/ then create_hotel(line, Core::Entities::Hotel)
        else
          raise Core::InvalidSegmentError, "Unknown segment type: #{line}"
        end
      end

      def create_transport(line, klass)
        match = line.match(/(\w+) (\w{3}) (\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}) -> (\w{3}) (\d{2}:\d{2})/)

        raise Core::InvalidSegmentError, "Invalid transport format: #{line}" unless match

        origin = match[2]
        destination = match[5]
        departure = parse_datetime(match[3], match[4])
        arrival = parse_datetime(match[3], match[6])

        arrival = arrival.next_day if next_day?(departure, arrival)

        klass.new(
          origin: origin,
          destination: destination,
          start_time: departure,
          end_time: arrival
        )
      rescue ArgumentError => e
        raise Core::InvalidDateError, "Invalid date in: #{line} - #{e.backtrace}"
      end

      def next_day?(departure, arrival)
        arrival < departure
      end

      def create_hotel(line, klass)
        hotel_pattern = /Hotel (\w{3}) (\d{4}-\d{2}-\d{2}) -> (\d{4}-\d{2}-\d{2})/
        match = hotel_pattern.match(line)
        raise Core::InvalidSegmentError, "Invalid hotel format: #{line}" unless match

        location = match[1]
        check_in = parse_date(match[2])
        check_out = parse_date(match[3])

        klass.new(
          location: location,
          start_time: DateTime.new(check_in.year, check_in.month, check_in.day, 14),
          end_time: DateTime.new(check_out.year, check_out.month, check_out.day, 10)
        )
      rescue ArgumentError => e
        raise Core::InvalidDateError, "Invalid date in: #{line} - #{e.backtrace}"
      end

      def log_parse_error(message)
        @logger_instance.log_error "[Parse Error] #{message}"
      end
    end
  end
end
