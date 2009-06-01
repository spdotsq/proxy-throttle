require 'storage/default'
require 'MemCache'

class Storage::Memcache < Storage::Default
  
  def connect()
    return MemCache.new(['0.0.0.0:11211'])
  end
  
end
