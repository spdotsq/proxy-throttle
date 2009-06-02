require 'storage'
require 'rule'

class Throttle
  
  def initialize(application, options={})
    @application = application
    @options = options
    @storage = Storage.connect(options['storage'].keys[0], options['storage'][options['storage'].keys[0]])
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
    
    @application.call(environment)
  end
  
  def throttle(request, rule)
    key = rule.requestkey(request)
    value = @storage.get(key)
    if value.nil?
      value = "0"
      @storage.touch(key)
    end
    return false if rule.exceeds(value.to_i)
    @storage.incr(key) #TODO: increment only if succeded

    return true
  end
  
  def denied
    [403, {'Content-Type' => 'text/plain'}, ['Access denied']]
  end
  
  def limit_exceeded
    [503, {'Content-Type' => 'text/plain'}, ['Quota exceeded']]
  end
end
