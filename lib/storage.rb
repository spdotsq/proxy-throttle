module Storage
  
  def self.connect(system, options)
    connection = nil
    case system
    when 'redis'
      require 'storage/redis'
      options.each do |key, value|
        options[key.to_sym] = value
      end
      return Storage::Redis.new(options)
    when 'memcache'
      require 'storage/memcache'
      return Storage::Memcache.new(options)
    end
  end
  
end
