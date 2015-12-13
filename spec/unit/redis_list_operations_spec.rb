require 'spec_helper'
require 'redis'

describe 'redis lists' do
  let(:redis) { Redis.new }
  let(:key) { 'my_list' }

  after { redis.del(key) }

  describe '#lpush' do
    let(:values) { ["1", "2", "3"] }

    it 'pushes elements to the left' do
      redis.lpush(key, values)
      expect(redis.lrange(key, 0, -1)).to eq(["3", "2", "1"])
      redis.lpush(key, "4")
      expect(redis.lrange(key, 0, -1)).to eq(["4", "3", "2", "1"])
    end
  end

  describe '#rpush' do
    let(:values) { ["1", "2", "3"] }

    it 'pushes elements to the right' do
      redis.rpush(key, values)
      expect(redis.lrange(key, 0, -1)).to eq values
      redis.rpush(key, "4")
      expect(redis.lrange(key, 0, -1)).to eq(values + ["4"])
    end
  end

  describe '#lrange' do
    let(:values) { ["1", "2", "3"] }
    before { redis.lpush(key, values) }

    it 'returns correct elements depending on input' do
      expect(redis.lrange(key, 0, -1)).to eq values.reverse
      expect(redis.lrange(key, 0, 1)).to eq ["3", "2"]
      expect(redis.lrange(key, 0, 2)).to eq ["3", "2", "1"]
    end
  end

  describe '#lpop' do
    let(:values) { ["1", "2", "3"] }
    before { redis.lpush(key, values) }

    it 'returns correct elements depending on input' do
      expect(redis.lpop(key)).to eq "3"
      expect(redis.lpop(key)).to eq "2"
      expect(redis.lpop(key)).to eq "1"
    end
  end

  describe '#rpop' do
    let(:values) { ["1", "2", "3"] }
    before { redis.lpush(key, values) }

    it 'returns correct elements depending on input' do
      expect(redis.rpop(key)).to eq "1"
      expect(redis.rpop(key)).to eq "2"
      expect(redis.rpop(key)).to eq "3"
    end
  end

  describe '#ltrim' do
    let(:values) { ["1", "2", "3"] }
    before do
      redis.lpush(key, values)
      redis.rpush(key, ["5", "4"])
    end

    it 'returns correct elements depending on input' do
      redis.ltrim(key, 0, 1)
      expect(redis.lrange(key, 0, -1)).to eq(["3", "2"])
    end
  end

  describe 'blocking operations' do
    let(:values) { "1" }
    let(:blocked_redis) { Redis.new }
    before { redis.lpush(key, values) }

    it 'returns correct elements depending on input' do
      Thread.new {
        expect(blocked_redis.blpop(key, 0)).to eq([key, "1"])
        expect(blocked_redis.blpop(key, 0)).to eq([key, "2"])
      }
      Thread.new {
        sleep 0.2
        redis.lpush(key, "2")
      }
      sleep 0.3
      expect(redis.lpop(key)).to eq nil
    end
  end
end
