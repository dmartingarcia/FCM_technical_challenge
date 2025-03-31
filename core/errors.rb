module Core
  class Error < StandardError; end

  # File-related errors
  class FileReadError < Error; end

  # Segment parsing errors
  class InvalidSegmentError < Error; end
  class InvalidDateError < Error; end

  # Business logic errors
  class EmptyItineraryError < Error; end
end
