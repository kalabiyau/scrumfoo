Bundler.setup(:default)

require 'scrum/config'
require 'scrum/storage'
require 'scrum/storage/redis'
require 'scrum/sprint'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/date'

module Scrum

  SPRINT_DAYS = OPTS.sprint_days
  FIRST_DAY   = OPTS.first_scrum_day

  class << self
    attr_accessor :storage
  end

  Scrum.storage = Scrum::Storage.new

end
