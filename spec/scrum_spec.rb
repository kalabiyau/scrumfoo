require 'spec_helper'

describe Scrum do

  it 'sets SPRINT_DAYS constant to config value' do
    expect(described_class::SPRINT_DAYS).to eq 10
  end

  it 'sets FIRST_DAY constant to config value parsed from string formatted as year-month-day' do
    expect(described_class::FIRST_DAY).to eq OPTS.first_scrum_day
  end

  it 'assigns self storage to Scrum::Storage instance' do
    expect(described_class.storage).to be_an_instance_of Scrum::Storage
  end

end

