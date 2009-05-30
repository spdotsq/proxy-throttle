$:.unshift File.join(File.dirname(__FILE__))
require 'backend'

class Proxy
  
  def initialize(options)
    @options = options
    @proxy = Backend.new(:host => options['host'], :port => options['port'].to_i)
  end
  
  def call(env)
    request = Rack::Request.new(env)
    # Proxy
    response = @proxy.forward(request, env)
    
    headers = {}
    response.to_hash.each {|k, v| headers[k.capitalize] = v.join}
    
    [response.code, headers, [response.body]]
  rescue
    [500, {'Content-Type' => 'text/plain'}, ["Error"]]
  end
  
end
