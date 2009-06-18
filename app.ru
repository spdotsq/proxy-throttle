require 'yaml'

require 'lib/proxy'
require 'lib/throttle'

use Rack::ContentLength

configuration = YAML.load_file('configuration/environment.yml')

if configuration['environment'] == 'development'
  use Rack::ShowExceptions
  use Rack::CommonLogger
end

use Throttle, configuration['throttler']

run Proxy.new(configuration['backend'])