# frozen_string_literal: true

module Core
  module Ports
    # Responsibility: Define logging contract
    # Methods:
    #   - log_info(message): Info-level logging
    #  - log_error(error): Error handling
    module LoggerPort
      def log_info(_message); end
      def log_error(_error); end
    end
  end
end
