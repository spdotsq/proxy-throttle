require 'storage/default'
require 'redis'

class Storage::Redis < Storage::Default
  
  def connect()
    return Redis.new(@options)
  end
  
  def reconnect()
    return connect()
  end
  
end
