# frozen_string_literal: true

module Core
  module Entities
    class Travel
      attr_reader :segments, :base

      def initialize(base:, segments: [])
        @base = base
        @segments = segments
      end

      def add_segment(segment)
        @segments << segment
      end

      def destination
        transports = @segments.select { |s| [Flight, Train].any? { |c| s.is_a?(c) } }
        destinations = transports.map(&:destination).reject { |d| d == @base }
        destinations.last || base
      end
    end
  end
end
