$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rack'

require 'meme_captain'

use Rack::ConditionalGet
use Rack::Sendfile

run MemeCaptain::Server
