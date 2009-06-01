class Storage::Default
  
  attr_reader :connection
  
  def initialize(options)
    @options = options
    @connection = connect()
  end
  
  def connect()
    raise 'Not implemented'
  end
  
  def get(key)
    return @connection.get(key)
  end
  
  def set(key, value)
    return @connection.set(key, value)
  end
  
  def incr(key)
    return @connection.incr(key)
  end
  
end
