# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Core::Entities::Flight do
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
      expect(object.hotel?).to be_falsey
    end
  end

  describe '#transport' do
    it 'returns true' do
      expect(object.transport?).to be_truthy
    end
  end
end
