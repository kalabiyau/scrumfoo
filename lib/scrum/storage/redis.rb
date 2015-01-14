class Scrum::Storage::Redis

  def initialize
    @redis = Redis.new(db: OPTS.redis['db'])
  end

  def extract(object)
    unless exists?(object)
      raise Scrum::NotStoredObjectAccess, "#{object.key} does not exist"
    end
    JSON.parse(@redis.get(object.key), symbolize_names: true)
  end

  def exists?(object)
    @redis.exists(object.key)
  end

  def store(object)
    @redis.set(object.key, object.to_json)
  end

end

