require 'lib/proxy'
require 'lib/throttle'

use Rack::ContentLength
# use Rack::Lint
# use Rack::ShowExceptions
# use Rack::CommonLogger

use Throttle

run Proxy.new