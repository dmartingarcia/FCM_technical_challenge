# frozen_string_literal: true

module Adapters
  module Printers
    class TextPrinter
      def initialize(travels, base, logger_instance: Adapters::Loggers::StdoutLogger.new)
        @travels = travels
        @base = base
        @logger_instance = logger_instance
      end

      def print
        @travels.each do |travel|
          @logger_instance.log_info("TRIP to #{travel.destination(@base)}")
          travel.segments.each do |segment|
            @logger_instance.log_info(format_segment(segment))
          end
          # INFO: add white line between travels
          @logger_instance.log_info('')
        end
      end

      private

      def format_segment(segment)
        case segment
        when Core::Entities::Flight, Core::Entities::Train
          format_transport(segment)
        when Core::Entities::Hotel
          format_hotel(segment)
        else
          raise Core::Errors::UnknownSegmentTypeError, "Unexpected #{segment.class} segment type"
        end
      end

      def format_transport(segment)
        "#{segment.class.to_s.split('::').last} from #{segment.origin} to #{segment.destination} " \
          "at #{segment.start_time.strftime('%Y-%m-%d %H:%M')} to #{segment.end_time.strftime('%Y-%m-%d %H:%M')}"
      end

      def format_hotel(segment)
        "Hotel at #{segment.location} on #{segment.start_time.strftime('%Y-%m-%d')} " \
          "to #{segment.end_time.strftime('%Y-%m-%d')}"
      end
    end
  end
end
