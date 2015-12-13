require 'spec_helper'

describe 'redis sets' do
  let(:redis) { Redis.new }
  let(:key) { 'myset' }

  after(:each) { redis.del(key) }

  describe 'basic operations' do
    let(:values) { [1, 2, 3, 4] }
    before { redis.sadd(key, values) }

    it '#smembers' do
      expect(redis.smembers(key).map(&:to_i)).to match_array(values)
    end

    it '#sismember' do
      expect(redis.sismember(key, 1)).to eq(true)
      expect(redis.sismember(key, 5)).to eq(false)
    end

    it '#spop' do
      expect(values.map(&:to_s)).to include(redis.spop(key))
      expect(redis.scard(key)).to eq(3)
    end

    it '#srandmember' do
      expect(values.map(&:to_s)).to include(redis.srandmember(key))
      expect(redis.scard(key)).to eq(4)
    end

    it '#scard' do
      expect(redis.scard(key)).to eq(4)
    end
  end

  describe 'set operations' do
    let(:values1) { ["a", "b", "c"] }
    let(:values2) { ["c", "d"] }
    let(:key2) { "myset2" }
    let(:key3) { "myset3" }

    before do
      redis.sadd(key, values1)
      redis.sadd(key2, values2)
    end

    after do
      redis.del(key2)
      redis.del(key3)
    end

    it '#sinter' do
      expect(redis.sinter(key, key2)).to match_array(["c"])
    end

    it '#sunion' do
      expect(redis.sunion(key, key2)).to match_array(["a", "b", "c", "d"])
    end

    it '#sunionstore' do
      redis.sunionstore(key3, [key, key2])
      expect(redis.smembers(key3)).to match_array(["a", "b", "c", "d"])
    end
  end
end
