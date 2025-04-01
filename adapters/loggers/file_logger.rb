# frozen_string_literal: true

module Adapters
  module Loggers
    class FileLoggerLogger
      include LoggerPort

      def initialize(log_file: 'app.log')
        @logger = Logger.new(log_file)
      end

      def log_info(message)
        @logger.info(message)
      end

      def log_error(error)
        @logger.error("[ERROR] #{error.message}\n#{error.backtrace.join("\n")}")
      end
    end
  end
end
