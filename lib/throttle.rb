require 'redis'

class Throttle
  def initialize(app, opts={})
    @app = app
    @opts = {:per_hour => 3, :key_field => 'apikey'}.merge(opts)
    @redis = Redis.new
  end
  
  def call(env)
    request = Rack::Request.new(env)
    
    
    @opts['rules'].each do |name, rule|
      if request.fullpath.match(rule['endpoint'])
        p "Matched rule #{name}"
        return limit_exceeded unless throttle(request, rule, name)
      end
    end
    
    @app.call(env)
  end
  
  def throttle(request, rule, name = '')
    # Create the unique client identifier
    client_identifier = request.ip #if rule['client']['identifier'] == :ip
    # Create the unique request identifier
    request_identifier = request.request_method # if ...
    # Check the db for the key
    p key = "#{name}_#{client_identifier}_#{request_identifier}_" +
        "#{Time.now.strftime("%Y-%m-%d")}"
    # Apply the rule
    p @redis[key]
    return false if @redis[key].to_i >= rule['limit']
    @redis.incr(key) #TODO increment only if succeded

    return true
  end
  
  def denied
    [403, {'Content-Type' => 'text/plain'}, ['Access denied']]
  end
  
  def limit_exceeded
    [503, {'Content-Type' => 'text/plain'}, ['Quota exceeded']]
  end
end