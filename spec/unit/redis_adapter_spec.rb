require 'spec_helper'

describe 'redis basic key/value operations' do
  let(:redis) { Redis.new(db: database_number) }

  let(:database_number) { 10 }
  let(:value) { 2 }

  describe '#set, #get' do
    let(:key) { "some_key" }
    let(:value) { "some_value" }

    after(:each) do
      redis.del(key)
    end

    context 'simple keys and values' do
      before { redis.set(key, value) }

      it 'returns value' do
        expect(redis.get(key)).to eq value
      end

      context 'when key has spaces' do
        let(:key) { "some key" }

        it 'returns value' do
          expect(redis.get(key)).to eq value
        end
      end

      context 'when key is spaces' do
        let(:key) { "  " }

        it 'returns value' do
          expect(redis.get(key)).to eq value
        end
      end

      context 'when requesting multiple times' do
        it 'returns value' do
          expect(redis.get(key)).to eq value
          expect(redis.get(key)).to eq value
          expect(redis.get(key)).to eq value
        end
      end

      context 'when storing hash in JSON' do
        let(:value) { { my: :hash }.to_json }

        it 'returns value in string' do
          expect(redis.get(key)).to eq value
        end

        it 'lets you JSON parse value back to hash' do
          expect(JSON.parse(redis.get(key))).to eq({ 'my' => 'hash' })
        end
      end

      context 'when storing object' do
        let(:value) { MockObject.new(3) }

        it 'stores object memory address' do
          expect(redis.get(key)).to eq value.to_s
        end
      end

      context 'when storing array json' do
        let(:value) { [1, 2, 3].to_json }

        it 'returns value in string' do
          expect(redis.get(key)).to eq value.to_s
        end

        it 'lets you json parse value back to array' do
          expect(JSON.parse(redis.get(key))).to eq [1, 2, 3]
        end
      end
    end

    context 'when multiple databases' do
      let(:redis2) { Redis.new(db: database_number + 1) }

      context 'when simple key/value' do
        let(:key) { "some_key" }
        let(:value) { "some_value" }
        before(:each) { redis.set(key, value) }

        it 'does not store it to other database' do
          expect(redis.get(key)).to eq value
          expect(redis2.get(key)).to eq nil
        end
      end
    end

    context 'when setting options' do
      before { redis.set(key, value, options) }

      context 'when setting expire time in seconds' do
        let(:options) { { ex: 1 }}

        it 'expires the value in 0.1 seconds' do
          expect(redis.get(key)).to eq value
          sleep 1.1
          expect(redis.get(key)).to eq nil
        end
      end

      context 'when setting expire time in milliseconds' do
        let(:options) { { px: 100 }}

        it 'expires the value in 100 milliseconds' do
          expect(redis.get(key)).to eq value
          sleep 0.2
          expect(redis.get(key)).to eq nil
        end
      end
    end
  end

  describe '#del' do
    let(:key1) { 1 }
    let(:key2) { 2 }
    let(:key3) { 3 }

    before do
      redis.set(key1, "value")
      redis.set(key2, "value")
      redis.set(key3, "value")
    end

    after { redis.del([key1, key2, key3]) }

    context 'when deleting single key' do
      it 'deletes single pair' do
        redis.del(key1)
        expect(redis.get(key1)).to eq nil
        expect(redis.get(key2)).to eq "value"
        expect(redis.get(key3)).to eq "value"
      end
    end

    context 'when deleting multiple keys' do
      it 'deletes all pairs' do
        redis.del([key1, key2, key3])
        expect(redis.get(key1)).to eq nil
        expect(redis.get(key2)).to eq nil
        expect(redis.get(key3)).to eq nil
      end
    end
  end

  describe '#incr' do
    let(:key) { "some_key" }

    before { redis.set(key, value) }
    after { redis.del(key) }

    context 'when incrementing number' do
      let(:value) { 4 }

      it 'returns incremented value' do
        expect(redis.incr(key)).to eq(value + 1)
        expect(redis.get(key).to_i).to eq(value + 1)
      end
    end

    context 'when incrementing string' do
      let(:value) { "tere" }

      it 'returns raises error' do
        expect{redis.incr(key)}.to raise_error(Redis::CommandError)
      end
    end
  end

  describe '#multi' do
    let(:key1) { "a" }
    let(:key2) { "b" }

    after { redis.del([key1, key2]) }

    it 'executes commands in transaction' do
      redis.multi do
        redis.set(key1, value)
        redis.incr(key1)
        redis.set(key2, value)
      end
      expect(redis.get(key1).to_i).to eq(value + 1)
      expect(redis.get(key2).to_i).to eq value
    end

    context 'if error in between in transaction' do
      let(:value) { "c" }

      it 'executes commands that dont throw' do
        expect do
          redis.multi do
            redis.set(key1, value)
            redis.incr(key1)
            redis.set(key2, value)
          end
        end.to raise_error(Redis::CommandError)
        expect(redis.get(key1)).to eq value
        expect(redis.get(key2)).to eq value
      end

      it 'sets future values' do
        future = nil
        redis.multi do
          future = redis.set(key1, value)
        end
        expect(future.value).to eq "OK"
      end
    end

    context 'when in transaction and using 2 threads' do
      let(:transactional_redis) { Redis.new(db: database_number) }

      it 'executes transactional commands after non-transactional commands' do
        transactional_value1 = nil
        transactional_value2 = nil
        non_transactional_value = nil
        transactional_redis.set(key1, value)
        Thread.new {
          transactional_redis.multi do
            transactional_redis.incr(key1)
            transactional_value1 = transactional_redis.get(key1)
            sleep 0.2
            transactional_value2 = transactional_redis.get(key1)
          end
        }
        Thread.new {
          sleep 0.1
          redis.incr(key1)
          non_transactional_value = redis.get(key1)
        }
        sleep 0.4

        expect(transactional_value1.value.to_i).to eq(value + 2)
        expect(transactional_value2.value.to_i).to eq(value + 2)
        expect(non_transactional_value.to_i).to eq(value + 1)
        expect(redis.get(key1).to_i).to eq(value + 2)
      end
    end
  end
end

