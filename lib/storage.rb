module Storage
  
  def self.connect(system, options)
    connection = nil
    case system
    when 'redis'
      require 'storage/redis'
      return Storage::Redis.new(options)
    when 'memcache'
      require 'storage/memcache'
      return Storage::Memcache.new(options)
    end
  end
  
end
