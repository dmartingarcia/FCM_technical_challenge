# frozen_string_literal: true

require_relative '../../core/ports/logger_port'
require 'logger'

module Adapters
  module Loggers
    class StdoutLogger
      include LoggerPort

      def initialize
        @logger = Logger.new($stdout)
      end

      def log_info(message)
        @logger.info(message)
      end

      def log_error(error)
        @logger.error("[ERROR] #{error}")
      end
    end
  end
end
