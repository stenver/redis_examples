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

    def incr(key)
      @redis.incr(key)
    end

    def multi(&block)
      @redis.multi(&block)
    end
  end
end
