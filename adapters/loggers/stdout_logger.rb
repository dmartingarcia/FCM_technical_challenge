# frozen_string_literal: true

require 'logger'

module Adapters
  module Loggers
    class StdoutLogger
      include Core::Ports::LoggerPort

      def initialize
        @logger = Logger.new($stdout)
        # INFO: remove prefixes with a custom formatter
        @logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
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
