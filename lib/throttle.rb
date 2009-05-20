require 'redis'

class Throttle
  def initialize(app, opts={})
    @app = app
    @opts = {:per_hour => 3, :key_field => 'apikey'}.merge(opts)
    @redis = Redis.new
  end
  
  def call(env)
    request = Rack::Request.new(env)
    
    if request[@opts[:key_field]]
      p key = "#{request[@opts[:key_field]]}_#{Time.now.strftime("%Y-%m-%d-%H")}"
      p @redis[key]
      return limit_exceeded if @redis[key].to_i >= @opts[:per_hour]
      @redis.incr(key)
    else
      return denied
    end
    
    @app.call(env)
  end
  
  def denied
    [403, {'Content-Type' => 'text/plain'}, ['Access denied']]
  end
  
  def limit_exceeded
    [503, {'Content-Type' => 'text/plain'}, ['Quota exceeded']]
  end
end