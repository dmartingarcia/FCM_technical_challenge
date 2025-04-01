# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Core::Entities::Hotel do
  subject(:object) do
    described_class.new(
      location: 'BCN',
      start_time: DateTime.new(2023, 1, 5),
      end_time: DateTime.new(2023, 1, 10)
    )
  end

  describe '#hotel?' do
    it 'returns true' do
      expect(object).to be_hotel
    end
  end

  describe '#transport' do
    it 'returns false' do
      expect(object).not_to be_transport
    end
  end

  describe 'connection_to?' do
    it 'returns true as both hotels are connected' do
      connection = described_class.new(
        location: 'BCN',
        start_time: DateTime.new(2023, 1, 10),
        end_time: DateTime.new(2023, 1, 11)
      )
      expect(object).to be_connection_to(connection)
    end
  end
end
