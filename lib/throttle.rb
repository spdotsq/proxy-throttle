require 'redis'
require 'rule'

class Throttle
  
  def initialize(application, options={})
    @application = application
    @options = options
    @redis = Redis.new({:host => options['storage'][options['storage'].keys[0]]['host'], :port => options['storage'][options['storage'].keys[0]]['port']})
    # Initialize rules
    @rules = []
    @options['throttler']['rules'].each do |name, rule|
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
    
    @application.call(environment)
  end
  
  def throttle(request, rule)
    key = rule.requestkey(request)
    p key
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