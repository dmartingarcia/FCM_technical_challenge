# spec/adapters/loggers/null_logger_spec.rb

require 'spec_helper'

RSpec.describe Adapters::Loggers::NullLogger do
  let(:logger) { described_class.new }
  let(:test_error) { StandardError.new('Something went wrong') }

  it 'implements the LoggerPort interface' do
    expect(logger).to be_a(Core::Ports::LoggerPort)
  end

  describe 'initial state' do
    it 'has empty info logs' do
      expect(logger.info_logs).to be_empty
    end

    it 'has empty error logs' do
      expect(logger.error_logs).to be_empty
    end
  end

  describe '#log_info' do
    context 'with string message' do
      it 'stores the message in info_logs' do
        logger.log_info('Processing started')
        expect(logger.info_logs).to include('Processing started')
      end
    end

    context 'with structured data' do
      it 'stores hash data in info_logs' do
        data = { trips: 3, segments: 5 }
        logger.log_info(data)
        expect(logger.info_logs).to include(data)
      end

      it 'stores complex objects in info_logs' do
        obj = Struct.new('SomeObject')
        logger.log_info(obj)
        expect(logger.info_logs).to include(obj)
      end
    end

    context 'with nil value' do
      it 'stores nil in info_logs' do
        logger.log_info(nil)
        expect(logger.info_logs).to include(nil)
      end
    end

    it 'accumulates multiple messages' do
      3.times { |i| logger.log_info("Message #{i}") }
      expect(logger.info_logs.count).to eq(3)
    end
  end

  describe '#log_error' do
    context 'with Error object' do
      it 'stores the error in error_logs' do
        logger.log_error(test_error)
        expect(logger.error_logs).to include(test_error)
      end

      it 'preserves error backtrace' do
        test_error.set_backtrace(['file.rb:123'])
        logger.log_error(test_error)
        logged_error = logger.error_logs.first
        expect(logged_error.backtrace).to eq(['file.rb:123'])
      end
    end

    context 'with string message' do
      it 'stores string in error_logs' do
        logger.log_error('Critical failure')
        expect(logger.error_logs).to include('Critical failure')
      end
    end

    context 'with structured data' do
      it 'stores hash data in error_logs' do
        error_data = { code: :timeout, details: 'Request timed out' }
        logger.log_error(error_data)
        expect(logger.error_logs).to include(error_data)
      end
    end

    context 'with nil value' do
      it 'stores nil in error_logs' do
        logger.log_error(nil)
        expect(logger.error_logs).to include(nil)
      end
    end

    it 'accumulates multiple errors' do
      2.times { logger.log_error(test_error) }
      expect(logger.error_logs.count).to eq(2)
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
