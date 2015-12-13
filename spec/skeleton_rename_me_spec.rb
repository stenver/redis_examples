require 'spec_helper'

describe SkeletonRenameMe do
  subject { described_class.new(value) }

  let(:value) { 1 }

  it 'returns value' do
    expect(subject.value).to eq value
  end
end
