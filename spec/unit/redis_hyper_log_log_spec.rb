require 'spec_helper'

describe 'redis hyperloglog`' do
  let(:redis) { Redis.new }
  let(:key) { 'hyper_log' }

  after(:each) { redis.del(key) }

  describe '#pfcount' do
    let(:values) { 100000 }
    # https://en.wikipedia.org/wiki/HyperLogLog 2% when over 10 ^ 9 elements
    let(:delta) { values * 0.02}

    before { redis.pfadd(key, (1..values).map{|i| i}) }

    it 'puts the capitals into a hashmap' do
      expect(redis.pfcount(key)).to be_within(delta).of(values)
    end

    describe '#pfmerge' do
      let(:key2) {'hyper_log2'}
      let(:key3) {'hyper_log3'}

      before do
        redis.pfadd(key2, (1..values).map{|i| -i})
      end
      after do
        redis.del(key2)
        redis.del(key3)
      end

      it 'merges the logs' do
        redis.pfmerge(key3, [key, key2])
        expect(redis.pfcount(key)).to be_within(delta).of(values)
        expect(redis.pfcount(key2)).to be_within(delta).of(values)
        expect(redis.pfcount(key3)).to be_within(delta * 2).of(values * 2)
      end
    end
  end
end
