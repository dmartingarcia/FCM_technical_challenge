# frozen_string_literal: true

require 'logger'

module Adapters
  module Loggers
    # Responsibility: Logging implementation
    # Mainly implementes to avoid having log output in tests and use it as a spy class
    # Mocks a logger and stores the logs for further analysis
    # Implements LoggerPort interface
    class NullLogger
      include Core::Ports::LoggerPort
      attr_reader :info_logs, :error_logs

      def initialize
        @info_logs = []
        @error_logs = []
      end

      def log_info(message)
        @info_logs << message
      end

      def log_error(error)
        @error_logs << error
      end
    end
  end
end
