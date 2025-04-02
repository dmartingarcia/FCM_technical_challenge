# spec/adapters/loggers/stdout_logger_spec.rb

require 'spec_helper'

RSpec.describe Adapters::Loggers::StdoutLogger do
  let(:logger) { described_class.new }

  it 'implements the LoggerPort interface' do
    expect(logger).to be_a(Core::Ports::LoggerPort)
  end

  describe '#log_info' do
    context 'with simple message' do
      it 'outputs message to stdout' do
        expect { logger.log_info('Processing started') }.to output("Processing started\n").to_stdout
      end
    end

    context 'with structured data' do
      it 'outputs formatted message' do
        expect { logger.log_info({ trips: 3, segments: 10 }) }.to output(include('{trips: 3, segments: 10}')).to_stdout
      end
    end

    context 'with empty message' do
      it 'outputs blank line' do
        expect { logger.log_info('') }.to output("\n").to_stdout
      end
    end
  end

  describe '#log_error' do
    context 'with Error object' do
      let(:error) { StandardError.new('Invalid segment format') }

      it 'outputs error message' do
        expect { logger.log_error(error) }.to output(include('[ERROR] Invalid segment format')).to_stdout
      end

      it 'includes backtrace when present' do
        error.set_backtrace(['file.rb:123:in `parse'])
        expect { logger.log_error(error) }.to output(include('[ERROR] Invalid segment format')).to_stdout
      end
    end

    context 'with string message' do
      it 'outputs raw message' do
        expect { logger.log_error('Critical failure') }.to output(include('Critical failure')).to_stdout
      end
    end

    context 'with structured error data' do
      it 'outputs formatted details' do
        error = { code: :invalid_input, details: 'Missing base location' }
        expect do
          logger.log_error(error)
        end.to output(include('{code: :invalid_input, details: "Missing base location"}')).to_stdout
      end
    end
  end

  describe 'configuration' do
    it 'does not include timestamps' do
      expect { logger.log_info('Test timestamp') }.not_to output(match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)).to_stdout
    end

    it 'does not include process IDs' do
      expect { logger.log_info('Test PID') }.not_to output(/#\d+/).to_stdout
    end
  end

  describe 'interface contract' do
    it 'implements required LoggerPort methods' do
      expect(logger).to respond_to(:log_info).with(1).argument
      expect(logger).to respond_to(:log_error).with(1).argument
    end

    it 'does not implement unexpected methods' do
      expect(logger).not_to respond_to(:log_warn)
      expect(logger).not_to respond_to(:log_debug)
    end
  end
end
