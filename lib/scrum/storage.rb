require 'redis'

module Scrum

  class NotStoredObjectAccess < StandardError; end

  class Storage

    attr_reader :interface

    def initialize
      @interface = Scrum::Storage.const_get(OPTS.storage, false).new
    end

    def extract(object)
      @interface.extract(object)
    end

    def exists?(object)
      @interface.exists?(object)
    end

    def store(object)
      @interface.store(object)
    end

  end

end
