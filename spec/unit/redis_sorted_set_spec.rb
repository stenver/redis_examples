require 'spec_helper'

describe 'redis sorted sets' do
  let(:redis) { Redis.new }
  let(:key) { 'mysortedset' }

  after(:each) { redis.del(key) }

  describe 'basic operations' do
    let(:values) { [1, "beginning", 3, 'end', 2, 'middle'] }
    before { redis.zadd(key, values) }

    it '#zrange' do
      expect(redis.zrange(key, 0, -1)).to eq(['beginning', 'middle', 'end'])
    end

    it '#zrange --withscores' do
      expect(redis.zrange(key, 0, -1, withscores: true)).to eq([['beginning', 1.0], ['middle', 2.0], ['end', 3.0]])
    end

    it '#zrange -inf' do
      expect(redis.zrangebyscore(key, '-inf', 2)).to eq(['beginning', 'middle'])
    end
  end

  describe 'lexiographical scores' do
    let(:values) { [1, "aaa", 1, "a", 1, 'bbb', 1, 'ccc'] }
    before { redis.zadd(key, values) }

    it '#zrangebylex' do
      expect(redis.zrangebylex(key, "[a", "(c")).to eq(['a', 'aaa', 'bbb'])
    end

    it '#zrangebylex' do
      expect(redis.zrangebylex(key, "[aa", "(c")).to eq(['aaa', 'bbb'])
    end
  end
end
