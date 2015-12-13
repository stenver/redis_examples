require 'spec_helper'

describe RedisExamples do
  subject { described_class }
  let(:database_number) { 10 }

  describe '#key_value_redis' do

    it 'returns KeyValueRedis' do
      expect(subject.key_value_redis(database_number)).to be_a RedisExamples::KeyValueRedis
    end
  end
end