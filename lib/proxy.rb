$:.unshift File.join(File.dirname(__FILE__))
require 'backend'

class Proxy
  
  def initialize(opts)
    @opts = opts
    @proxy = Backend.new(:host => opts['host'], :port => opts['port'].to_i)
  end
  
  def call(env)        
    # @proxy = @proxy || Backend.new(:host => opts['host'], :port => opts['port'].to_i)
    
    request = Rack::Request.new(env)
    
    # Proxy
    res = @proxy.forward(request, env)
    
    headers = {}
    res.to_hash.each {|k, v| headers[k.capitalize] = v.join}
    
    [res.code, headers, [res.body]]
  rescue
    [500, {'Content-Type' => 'text/plain'}, ["Error"]]
  end
  
end
