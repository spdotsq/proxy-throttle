class Rule
  
  attr_accessor :name, :limit, :endpoint
  
  def initialize(name, options)
    @options = options
    unless self.validate()
      # raise appropriate exception
    end
    @name     = name
    @limit    = @options['limit']
    @endpoint = @options['endpoint']
  end
  
  def validate
    # TODO: implement rule validation
    return true
  end
  
  def match(request)
    return request.fullpath.match(self.endpoint)
  end
  
  def clientkey(request)
    # key = ""
    # if not @clientkeys
    #   # Set the clientkeys here first or 
    #   # default it to IP if it wasn't set
    #   @clientkeys = ["ip"]
    # end
    # if @clientkeys
    #   # Mappings
    #   @clientkeys.each do |key|
    #     case key
    #     when "ip"
    #       key = key + request.ip
    #     when "method"
    #       key = key + request.method
    #     end
    #   end
    # end
    # return key
    return ""
  end
  
  def timekey(request)
    # if @options['time'] == 'day'
    #   return Time.now.strftime("%Y-%m-%d")
    # end
    # if @options['time'] == 'hour'
    #   return Time.now.strftime("%Y-%m-%d-%H")
    # end
    return ""
  end
  
  def exceeds(value)
    return value >= @rule.limit
  end
  
  def requestkey(request)
    return "#{self.name}_#{self.clientkey(request)}_#{self.timekey(request)}"
  end
end
