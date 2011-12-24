$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'mongo'
require 'mongo_mapper'
require 'rack'

require 'meme_captain'

use Rack::ConditionalGet
use Rack::Sendfile

use Rack::Static, :urls => %w{/tmp}, :root => 'public'

MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = 'memecaptain'

MemeCaptain::MemeData.ensure_index :meme_id

MemeCaptain::MemeData.ensure_index [
  [:source_url, 1],
  [:top_text, 1],
  [:bottom_text, 1],
]

run MemeCaptain::Server
