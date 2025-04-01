require 'spec_helper'

RSpec.describe 'Zeitwerk' do
  it 'loads all files without errors' do
    expect { FcmTechnicalChallenge::Loader.setup }.not_to raise_error
    expect(Zeitwerk::Registry.loaders.count).to eq(1)
  end

  it 'eager loads in production' do
    original_env = ENV.fetch('RACK_ENV', 'development')
    ENV['RACK_ENV'] = 'production'
    expect { FcmTechnicalChallenge::Loader.setup }.not_to raise_error
    ENV['RACK_ENV'] = original_env
  end
end