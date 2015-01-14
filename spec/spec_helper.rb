require 'simplecov'
SimpleCov.start

require 'scrum'
require 'vcr'
require 'chronic'

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false
  end

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  #config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
  config.extend VCR::RSpec::Macros
end

OPTS.trello['scrum_enabled_board']  = 'hntyZ1yU'
OPTS.trello['member_token']         = '2b36c46cc6a9d86f75533a66e4f335e3614b22219d1e5f9628ff9f169bdce593'
OPTS.trello['developer_public_key'] = 'ca558b78821d8fffa570287dceb50432'
