require 'spec_helper'
require 'ap'

describe Scrum::Sprint do

  use_vcr_cassette 'get board'

  describe '.new' do

    before do
      allow_any_instance_of(described_class).to receive(:get_stored_days)
    end

    it 'can be initialized via sprint number' do
      expect(described_class.new(number: 500).number).to eq 500
    end

    it 'determines sprint number if not specified' do
      expect_any_instance_of(described_class).to receive(:determine_sprint_number).and_return(777)
      expect(described_class.new.number).to eq 777
    end

    it 'get stored days from storage' do
      expect_any_instance_of(described_class).to receive(:get_stored_days)
      described_class.new
    end

    it 'populates board instance' do
      expect(subject.board).to be_an_instance_of(Scrum::Board)
    end

    it 'populates days with empty array' do
      expect(subject.days).to eq []
    end

  end

  describe '#determine_sprint_number' do

    it 'memoizes determine_sprint_number variable' do
      subject.determine_sprint_number
      expect(subject.determine_sprint_number).to be subject.determine_sprint_number
    end

    it 'gets number of sprint based on sprint_timeline' do
      subject.instance_variable_set(:@determine_sprint_number, nil)
      allow(subject).to receive(:sprint_timeline).and_return({1 => Date.today..Date.today})
      expect(subject.determine_sprint_number).to eq 1
    end

  end

  describe 'sprint_range' do

    it 'determines range of a sprint based on number of a sprint' do
      allow(subject).to receive(:sprint_timeline).and_return({77 => 1..3})
      subject.instance_variable_set(:@number, 77)
      expect(subject.sprint_range).to eq 1..3
    end

  end

  describe 'get_stored_days' do

    it 'calculates next sprint day based on current date' do
      expect(subject).to receive(:next_sprint_day).at_least(1).times.and_call_original
      subject.get_stored_days
    end

    it 'builds a day instance' do
      expect(Scrum::Day).to receive(:new).at_least(1).times.and_call_original
      subject.get_stored_days
    end

    it 'breaks loop if instantiated day is in future' do
      expect(Scrum::Day).to receive(:new).exactly(:once).and_return instance_double('Day', date: Date.tomorrow)
      described_class.new
    end

    it 'breaks loop if instantiated day is today' do
      expect(Scrum::Day).to receive(:new).exactly(:once).and_return instance_double('Day', date: Date.today)
      described_class.new
    end

    it 'stores days instances in days variable' do
      described_class.new.days.each do |day|
        expect(day).to be_an_instance_of Scrum::Day
      end
    end

    it 'pulls days on iteration' do
      pull_count = 0
      allow_any_instance_of(Scrum::Day).to receive(:pull) { pull_count += 1 }
      described_class.new
      expect(1..Scrum::SPRINT_DAYS).to include(pull_count)
    end

  end

  describe '#committed' do

    use_vcr_cassette 'get column data'

    it 'summaraze all the defined numbers in names' do
      expect(described_class.new.committed).to eq 11
    end

  end

  describe '#currently_done_points' do

    it 'gets done_as_of_today from board instance' do
      expect(subject.board).to receive(:done_as_of_today)
      subject.currently_done_points
    end

  end

  describe '#ideal_burndown' do

    it 'calculates array of descreasing estimated_committment by medium points per day to cover sprint in time' do
      allow(subject).to receive(:committed).and_return(100)
      expect(subject.ideal_burndown).to eq [100, 90.0, 80.0, 70.0, 60.0, 50.0, 40.0, 30.0, 20.0, 10.0, 0.0]
      allow(subject).to receive(:committed).and_return(15)
      expect(subject.ideal_burndown).to eq [15, 13.5, 12.0, 10.5, 9.0, 7.5, 6.0, 4.5, 3.0, 1.5, 0.0]
      allow(subject).to receive(:committed).and_return(333)
      expect(subject.ideal_burndown).to eq [333.0, 299.7, 266.4, 233.1, 199.8, 166.5, 133.2, 99.9, 66.6, 33.3, 0.0]
    end

  end

  describe '#labels' do

    it 'builds hash of labels for X axis where key is day number and value is label of it' do
      stub_const('Scrum::SPRINT_DAYS', 3)
      expect(subject.labels).to eq({ 0 => '0', 1 => '1', 2 => '2', 3 => '3' })
      stub_const('Scrum::SPRINT_DAYS', 4)
      expect(subject.labels).to eq({ 0 => '0', 1 => '1', 2 => '2', 3 => '3', 4 => '4' })
    end

  end

  describe '#burndown_array' do

    use_vcr_cassette 'get column data'

    it 'builds array of committed points per sprint minus done points per specific day and commited points on first position' do
      days = [
        instance_double('Day', done_points: 11),
        instance_double('Day', done_points: 6),
      ]
      allow(subject).to receive(:days).and_return(days)
      allow(subject).to receive(:committed).and_return(17)
      expect(subject.burndown_array).to eq [17, 6, 11]
    end

  end

  describe '#start_date' do

    it 'selects first day of sprint range' do
      allow(subject).to receive(:sprint_timeline).and_return({ 1 => 1..3 })
      allow(subject).to receive(:number).and_return(1)
      expect(subject.start_date).to eq 1
    end

  end

  describe '#end_date' do

    it 'selects last day of sprint range' do
      allow(subject).to receive(:sprint_timeline).and_return({ 6 => 7..12 })
      allow(subject).to receive(:number).and_return(6)
      expect(subject.end_date).to eq 12
    end

  end

  describe '#sprint_timeline' do

    it 'builds a hash of 100 sprints' do
      expect(subject.send(:sprint_timeline).count).to eq 100
    end

    it 'holds a sprint number as a key' do
      expect(subject.send(:sprint_timeline).keys).to match_array((1..100).to_a)
    end

    it 'holds dates range as a value' do
      expected_sprint_range = Scrum::FIRST_DAY..Scrum::FIRST_DAY + 2.weeks - 1.day
      expect(subject.send(:sprint_timeline).values.first).to eq(expected_sprint_range)
    end

    it 'next date range for next sprint should be 1 day after the end of last sprint' do
      expected_sprint_range = (Scrum::FIRST_DAY..Scrum::FIRST_DAY + 2.weeks - 1.day).last
      expect(subject.send(:sprint_timeline).values[1].first).to eq(expected_sprint_range + 1.day)
    end

  end

  describe '#next_sprint_day' do

    it 'choose next sprint day from range skipping Sat and Sun' do
      test_sprint_range = [
        Chronic.parse('next Sat').to_date,
        Chronic.parse('next Sun').to_date,
        Chronic.parse('next Mon').to_date
      ]
      allow(subject).to receive(:sprint_range).and_return(test_sprint_range)
      expect(subject.send(:next_sprint_day, 1)).to eq Chronic.parse('next Mon').to_date
    end

  end

end
