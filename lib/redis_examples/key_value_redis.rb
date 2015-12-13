class RedisExamples
  class RedisAdapter
    def initialize(database_number)
      @redis = Redis.new(db: database_number)
    end

    def set(key, value, options={})
      @redis.set(key, value)
    end

    def get(key)
      @redis.get(key)
    end

    def del(key)
      @redis.del(key)
    end
  end
end
