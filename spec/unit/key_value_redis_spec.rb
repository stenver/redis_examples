require 'spec_helper'

describe RedisExamples::RedisAdapter do
  subject { described_class.new(database_number) }

  let(:database_number) { 10 }
  let(:value) { 1 }

  describe '#set, #get' do
    let(:key) { "some_key" }
    let(:value) { "some_value" }

    after(:each) do
      subject.del(key)
    end

    context 'simple keys and values' do
      before { subject.set(key, value) }

      it 'returns value' do
        expect(subject.get(key)).to eq value
      end

      context 'when key has spaces' do
        let(:key) { "some key" }

        it 'returns value' do
          expect(subject.get(key)).to eq value
        end
      end

      context 'when key is spaces' do
        let(:key) { "  " }

        it 'returns value' do
          expect(subject.get(key)).to eq value
        end
      end

      context 'when requesting multiple times' do
        it 'returns value' do
          expect(subject.get(key)).to eq value
          expect(subject.get(key)).to eq value
          expect(subject.get(key)).to eq value
        end
      end

      context 'when storing hash in JSON' do
        let(:value) { { my: :hash }.to_json }

        it 'returns value in string' do
          expect(subject.get(key)).to eq value
        end

        it 'lets you JSON parse value back to hash' do
          expect(JSON.parse(subject.get(key))).to eq({ 'my' => 'hash' })
        end
      end

      context 'when storing object' do
        let(:value) { MockObject.new(3) }

        it 'stores object memory address' do
          expect(subject.get(key)).to eq value.to_s
        end
      end

      context 'when storing array json' do
        let(:value) { [1, 2, 3].to_json }

        it 'returns value in string' do
          expect(subject.get(key)).to eq value.to_s
        end

        it 'lets you json parse value back to array' do
          expect(JSON.parse(subject.get(key))).to eq [1, 2, 3]
        end
      end
    end

    context 'when multiple databases' do
      let(:redis2) { described_class.new(database_number + 1) }

      context 'when simple key/value' do
        let(:key) { "some_key" }
        let(:value) { "some_value" }
        before { subject.set(key, value) }

        it 'does not store it to other database' do
          expect(subject.get(key)).to eq value
          expect(redis2.get(key)).to eq nil
        end
      end
    end

    context 'when setting options' do
      before { subject.set(key, value, options) }

      context 'when setting expire time in seconds' do
        let(:options) { { ex: 0.1 }}

        it 'expires the value in 0.1 seconds' do
          expect(subject.get(key)).to eq value
          sleep 0.1
          expect(subject.get(key)).to eq value
        end
      end

      context 'when setting expire time in milliseconds' do
        let(:options) { { px: 100 }}

        it 'expires the value in 100 milliseconds' do
          expect(subject.get(key)).to eq value
          sleep 0.1
          expect(subject.get(key)).to eq value
        end
      end
    end
  end

  describe '#del' do
    let(:key1) { 1 }
    let(:key2) { 2 }
    let(:key3) { 3 }

    before do
      subject.set(key1, "value")
      subject.set(key2, "value")
      subject.set(key3, "value")
    end

    context 'when deleting single key' do
      it 'deletes single pair' do
        subject.del(key1)
        expect(subject.get(key1)).to eq nil
        expect(subject.get(key2)).to eq "value"
        expect(subject.get(key3)).to eq "value"
      end
    end

    context 'when deleting multiple keys' do
      it 'deletes all pairs' do
        subject.del([key1, key2, key3])
        expect(subject.get(key1)).to eq nil
        expect(subject.get(key2)).to eq nil
        expect(subject.get(key3)).to eq nil
      end
    end
  end
end

