# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Core::Entities::Train do
  subject(:object) do
    described_class.new(
      origin: 'BCN',
      destination: 'MAD',
      start_time: DateTime.new(2023, 1, 5),
      end_time: DateTime.new(2023, 1, 10)
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

  # INFO: Connection_to? is already tested on flight, and both classes behave in the same way for this function.
end
