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
    @rules.each do |rule|
      if rule.match(request)
        return limit_exceeded unless throttle(request, rule)
      end
    end
    
    @app.call(env)
  end
  
  def throttle(request, rule)
    key = rule.requestkey(request)
    return false if rule.exceeds(@redis[key].to_i)
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