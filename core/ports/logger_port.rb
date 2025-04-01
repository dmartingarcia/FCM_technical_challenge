# frozen_string_literal: true

module Core
  module Ports
    module LoggerPort
      def log_info(message); end
      def log_error(error); end
    end
  end
end
