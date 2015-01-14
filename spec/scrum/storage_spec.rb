require 'spec_helper'
class Scrum::Storage::DummyStorageImplementation; end

describe Scrum::Storage do

  describe '#new' do

    it 'populates interface with implementation instance' do
      expect(subject.interface).to_not be nil
    end

    it 'populates interface with implementation instance' do
      expect(subject.interface).to_not be nil
    end

    context 'default config' do

      it 'sets interface to redis instance' do
        expect(subject.interface).to be_instance_of Scrum::Storage::Redis
      end

    end

    context 'custom storage in config' do

      it 'uses defined via config storage implementation class' do
        allow(OPTS).to receive(:storage).and_return('DummyStorageImplementation')
        expect(subject.interface).to be_instance_of Scrum::Storage::DummyStorageImplementation
      end

    end

  end

  describe '#extract' do

    it 'send extract to the interface' do
      expect(subject.interface).to receive(:extract).with(:foo)
      subject.extract(:foo)
    end

  end

  describe '#exists?' do

    it 'send exists? to the interface' do
      expect(subject.interface).to receive(:exists?).with(:bar)
      subject.exists?(:bar)
    end

  end

  describe '#store' do

    it 'send store to the interface' do
      expect(subject.interface).to receive(:store).with(:baz)
      subject.store(:baz)
    end

  end

end
