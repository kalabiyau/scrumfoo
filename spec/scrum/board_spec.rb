require 'spec_helper'

describe Scrum::Board do

  subject { described_class.new(double('sprint')) }

  use_vcr_cassette 'get board'

  describe '#done_as_of_today' do

    it 'sums last week column and this week column' do
      allow(subject).to receive(:last_week_done_column).and_return(double(sum: 12))
      allow(subject).to receive(:first_week_done_column).and_return(double(sum: 21))
      expect(subject.done_as_of_today).to eq 33
    end

  end

end
