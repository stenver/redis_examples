require 'spec_helper'

describe 'redis hashmaps' do
  let(:redis) { Redis.new }
  let(:key) { 'country_capitals' }

  after(:each) { redis.del(key) }

  describe '#hmset' do
    let(:country_capitals) { { 'estonia' => 'tallinn', 'finland' => 'helsinki' }}

    it 'puts the capitals into a hashmap' do
      redis.hmset(key, country_capitals.flat_map{|k, v| [k, v]})
      expect(redis.hmget(key, country_capitals.keys)).to eq country_capitals.values
    end

    it 'puts the capitals into a hashmap' do
      redis.hset(key, 'estonia', 'tallinn')
      expect(redis.hmget(key, 'estonia')).to eq(['tallinn'])
    end
  end
  # No nested hashes :(
end
