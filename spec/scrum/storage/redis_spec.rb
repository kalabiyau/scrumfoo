require 'spec_helper'

describe Scrum::Storage::Redis do

  describe '#extract' do

    it 'raises if cannot find a key' do
      expect{subject.extract(double(key: '12562'))}.to raise_error  Scrum::NotStoredObjectAccess, '12562 does not exist'
    end

  end

end
