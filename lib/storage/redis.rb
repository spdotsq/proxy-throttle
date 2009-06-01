require 'storage/default'
require 'redis'

class Storage::Redis < Storage::Default
  
  def connect()
    p @options
    return Redis.new(@options)
  end
  
end
