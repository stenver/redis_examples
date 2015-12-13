require 'spec_helper'

describe 'redis bitmaps' do
  let(:redis) { Redis.new }
  let(:key) { 'bitmap' }

  after(:each) { redis.del(key) }

  describe 'basic operations' do
    it '#getbit' do
      redis.setbit(key, 10, 1)
      expect(redis.getbit(key, 10)).to eq 1
      expect(redis.getbit(key, 10 + 1)).to eq 0
    end

    it '#setbit' do
      redis.set(key, "abc")
      redis.setbit(key, 1, 0)
      expect(redis.get(key)).to eq "!bc"
    end

    it '#bitcount' do
      redis.set(key, "abc")
      expect(redis.bitcount(key)).to eq 10
    end
  end

  describe 'complex operations' do
    let(:key2) { 'bitmap2' }
    let(:destination_key) { 'bitmap3' }

    after do
      redis.del(key2)
      redis.del(destination_key)
    end

    it '#bitop' do
      redis.set(key, "abc")
      redis.set(key2, "cbd")
      redis.bitop("AND", destination_key, key, key2)
      expect(redis.get(destination_key)).to eq "ab`"
    end

    it '#bitop' do
      redis.set(key, "010")
      redis.set(key2, "101")
      redis.bitop("OR", destination_key, key, key2)
      expect(redis.get(destination_key)).to eq "111"
    end

    it '#bitop' do
      redis.set(key, "010")
      redis.set(key2, "101")
      redis.bitop("XOR", destination_key, key, key2)
      expect(redis.get(destination_key)).to eq "\u0001\u0001\u0001"
    end

    it '#bitop' do
      redis.setbit(key, 1, 1)
      redis.setbit(key, 0, 0)
      redis.setbit(key2, 1, 1)
      redis.setbit(key2, 0, 0)
      redis.bitop("NOT", key, key2)
      expect(redis.getbit(key, 0)).to eq 1
      expect(redis.getbit(key, 1)).to eq 0
    end
  end
end
