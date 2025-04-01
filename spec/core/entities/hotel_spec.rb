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
      expect(object.hotel?).to be_truthy
    end
  end

  describe '#transport' do
    it 'returns false' do
      expect(object.transport?).to be_falsey
    end
  end
end
