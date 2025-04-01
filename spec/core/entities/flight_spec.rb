# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Core::Entities::Flight do
  subject(:object) do
    described_class.new(
      origin: 'BCN',
      destination: 'MAD',
      start_time: DateTime.new(2023, 1, 5, 9, 0),
      end_time: DateTime.new(2023, 1, 5, 10, 0)
    )
  end

  describe '#hotel?' do
    it 'returns false' do
      expect(object).not_to be_hotel
    end
  end

  describe '#transport' do
    it 'returns true' do
      expect(object).to be_transport
    end
  end

  describe '#connection_to?' do
    it "returns true if it's within 24 hours" do
      connection = described_class.new(
        origin: 'MAD',
        destination: 'BER',
        start_time: DateTime.new(2023, 1, 5, 11, 0),
        end_time: DateTime.new(2023, 1, 5, 15, 0)
      )
      expect(object).to be_connection_to(connection)
    end

    it "returns false if it's not within 24 hours" do
      connection = described_class.new(
        origin: 'BCN',
        destination: 'MAD',
        start_time: DateTime.new(2023, 1, 6, 11, 0),
        end_time: DateTime.new(2023, 1, 6, 15, 0)
      )

      expect(object).not_to be_connection_to(connection)
    end

    it "returns true if doesn't match the destination of the first segment and the origin from the second one" do
      connection = described_class.new(
        origin: 'BER',
        destination: 'MAD',
        start_time: DateTime.new(2023, 1, 6, 11, 0),
        end_time: DateTime.new(2023, 1, 6, 15, 0)
      )

      expect(object).not_to be_connection_to(connection)
    end
  end
end
