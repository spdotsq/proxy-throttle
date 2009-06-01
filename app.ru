require 'yaml'

require 'lib/proxy'
require 'lib/throttle'

use Rack::ContentLength
# use Rack::Lint
use Rack::ShowExceptions
use Rack::CommonLogger

configuration = YAML.load_file('configuration/environment.yml')

use Throttle, configuration['throttler']

run Proxy.new(configuration['backend'])