require 'net/http'

class Backend
  class MethodNotAllowed < StandardError; end
  class ConnectionError < StandardError; end
  class TimeoutError < StandardError; end
    
  def initialize(opts)
    @opts = opts
    @http = Net::HTTP.new(@opts[:host], @opts[:port])
    @http.open_timeout = 10
    @http.read_timeout = 10
  end
  
  def forward(request, env)
    headers = {'X-Forwarded-by' => 'proxy-throttle'}.merge(@opts[:headers] || {})
    
    if request.get?
      response = @http.get(request.fullpath, headers)
    elsif request.post?
      data = env['rack.input'].read
      env['rack.input'].rewind

      headers['Content-Type'] = request.content_type
      headers['Content-Length'] = data.length.to_s
      response = @http.post(request.path_info, data, headers)
    else
      raise MethodNotAllowed
    end

    response
     
  rescue EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED => e
    raise ConnectionError
  rescue Timeout::Error, Errno::ETIMEDOUT => e
    raise TimeoutError
  end
end