$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rack'

require 'meme_captain'

use Rack::ConditionalGet
use Rack::Sendfile

use Rack::Static, :urls => %w{/tmp}, :root => 'public'

run MemeCaptain::Server
