require 'storage/default'
require 'MemCache'

class Storage::Memcache < Storage::Default
  
  def connect()
    return MemCache.new(['0.0.0.0:11211'])
  end
  
  def touch(key)
    return @connection.set(key, 0.to_s)
  end
  
end
