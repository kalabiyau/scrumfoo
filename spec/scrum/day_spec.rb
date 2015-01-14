require 'spec_helper'

describe Scrum::Day do

  describe '#pull' do

    context 'stored in backend' do

      before do
        allow(subject).to receive(:stored?).and_return true
      end

      it 'xtracts points from backend' do
        allow(Scrum.storage).to receive(:extract).with(subject).and_return({:points_done => 73})
        expect(subject).to receive(:done_points=).with(73)
        subject.pull
      end

    end

    context 'not yet stored in backend' do

      before do
        allow(subject).to receive(:stored?).and_return false
      end

      it 'xtracts points board done_as_of_today' do
        sprint = double('sprint', board: double('board', done_as_of_today: 73), number: 1)
        subject.instance_variable_set(:@sprint, sprint)
        expect(subject).to receive(:done_points=).with(73)
        subject.pull
      end

      it 'stores done_points to backend' do
        sprint = double('sprint', board: double('board', done_as_of_today: 73), number: 1)
        subject.instance_variable_set(:@sprint, sprint)
        expect(subject).to receive(:done_points=).with(73)
        expect(subject).to receive(:push)
        subject.pull
      end

    end

  end

end
