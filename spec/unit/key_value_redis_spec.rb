require 'spec_helper'

describe RedisExamples::KeyValueRedis do
  subject { described_class.new(database_number) }

  let(:database_number) { 10 }
  let(:value) { 1 }

  context 'when simple key/value' do
    let(:key) { "some_key" }
    let(:value) { "some_value" }

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

    context 'when storing hash' do
      let(:value) { { my: :hash } }

      it 'returns value' do
        expect(eval(subject.get(key))).to eq value
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
end

