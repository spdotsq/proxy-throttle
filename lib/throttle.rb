require 'redis'
require 'rule'

class Throttle
  
  def initialize(application, options={})
    @application = application
    @options = options
    @redis = Redis.new
    # Initialize rules
    @rules = []
    @options['rules'].each do |name, rule|
      @rules << Rule.new(name, rule)
    end
  end
  
  def call(environment)
    request = Rack::Request.new(environment)
    
    @rules.each do |name, rule|
      if rule.match(request)
        return limit_exceeded unless throttle(request, rule, name)
      end
    end
    
    @app.call(env)
  end
  
  def throttle(request, rule, name = '')
    # Create the unique client identifier
    client_identifier = request.ip
    # Create the unique request identifier
    key = "#{name}_#{client_identifier}_#{timekey(rule)}"
    p key
    # Apply the rule
    return false if @redis[key].to_i >= rule['limit']
    @redis.incr(key) #TODO increment only if succeded
    # @redis.expire(key, )

    return true
  end
  
  def denied
    [403, {'Content-Type' => 'text/plain'}, ['Access denied']]
  end
  
  def limit_exceeded
    [503, {'Content-Type' => 'text/plain'}, ['Quota exceeded']]
  end
end