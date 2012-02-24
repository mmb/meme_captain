$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'mongo'
require 'mongo_mapper'
require 'rack'
require 'rack/contrib/jsonp'
require 'rack/rewrite'

require 'meme_captain'

use Rack::ConditionalGet
use Rack::Sendfile
use Rack::JSONP

use Rack::Static, :urls => %w{/tmp}, :root => 'public'

MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = 'memecaptain'

MemeCaptain::MemeData.ensure_index :meme_id

MemeCaptain::MemeData.ensure_index [
  [:source_url, 1],
  [:texts, 1],
]

MemeCaptain::Upload.ensure_index :upload_id

MemeCaptain::SourceFetchFail.ensure_index :url

use Rack::Rewrite do
  rewrite %r{/([gi])\?(.+)}, lambda { |match, rack_env|
    result = match[0]

    if match[2].index('tt=') or match[2].index('tb=')
      q = Rack::Utils.parse_query(match[2])
      if q.key?('tt') or q.key?('tb')
        q['t1'] = q.delete('tt')  if q.key?('tt')
        q['t2'] = q.delete('tb')  if q.key?('tb')
        new_q = q.map { |k,v|
          "#{Rack::Utils.escape(k)}=#{Rack::Utils.escape(v)}" }.join('&')
        result = "#{match[1]}?#{new_q}"
      end
    end

    result
  }
end

run MemeCaptain::Server
