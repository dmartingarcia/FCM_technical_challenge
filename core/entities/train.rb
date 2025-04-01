# frozen_string_literal: true

module Core
  module Entities
    class Train
      include Core::Entities::Segment
      attr_reader :origin, :destination, :start_time, :end_time
    end
  end
end
