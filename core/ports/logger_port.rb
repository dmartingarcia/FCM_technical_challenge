# frozen_string_literal: true

module Core
  module Ports
    # Responsibility: Define logging contract
    # Methods:
    #   - log_info(message): Info-level logging
    #  - log_error(error): Error handling
    module LoggerPort
      def log_info(message)
        raise NotImplementedError, 'Subclasses must implement log_info(message)'
      end

      def log_error(error)
        raise NotImplementedError, 'Subclasses must implement log_error(error)'
      end
    end
  end
end
