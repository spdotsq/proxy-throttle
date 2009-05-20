$:.unshift File.join(File.dirname(__FILE__))
require 'backend'

class Proxy
  
  def call(env)        
    @proxy = @proxy || Backend.new(:host => '127.0.0.1', :port => 3001)
    
    request = Rack::Request.new(env)
    
    # Proxy
    res = @proxy.forward(request, env)
    
    headers = {}
    res.to_hash.each {|k, v| headers[k] = v.join}
    
    [200, headers, [res.body]]
  rescue
    [500, {'Content-Type' => 'text/plain'}, ["Error"]]
  end
end