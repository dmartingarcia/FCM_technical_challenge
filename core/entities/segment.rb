module Core
  module Entities
    module Segment
      # INFO: I prefer to use composition over inheritance as we can extend the logic of any entity independently of the previous assigned logic.
      def hotel?
        self.is_a?(Core::Entities::Hotel)
      end

      def transport?
        [Core::Entities::Flight, Core::Entities::Train].any? { |c| self.is_a?(c) }
      end
    end
  end
end