require "redis"

# Require all files in sub folder
Dir[File.dirname(__FILE__) + "/redis_examples/*.rb"].each {|f| require f}

class RedisExamples
  def self.key_value_redis(database_number)
    RedisAdapter.new(database_number)
  end
end
