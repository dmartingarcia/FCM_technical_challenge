# frozen_string_literal: true

module Core
  module Errors
    class Error < StandardError; end

    # File-related errors
    class FileReadError < Error; end

    # Segment parsing errors
    class InvalidSegmentError < Error; end
    class InvalidDateError < Error; end

    # Business logic errors
    class EmptyItineraryError < Error; end
    class UnknownSegmentTypeError < Error; end
  end
end
