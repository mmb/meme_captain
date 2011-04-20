require 'digest/sha1'

require 'curb'
require 'sinatra/base'

require 'meme_captain'

module MemeCaptain

  class Server < Sinatra::Base

    get '/' do
      @img_tag = if params[:u]
        "<img src=\"#{h request.fullpath.sub(%r{^/}, '/i')}\" />"
      else
        ''
      end

      @u = params[:u]
      @tt= params[:tt]
      @tb = params[:tb]

      erb :index
    end

    get '/i' do
      @processed_cache ||= MemeCaptain::FilesystemCache.new(
        'img_cache/processed')
      @source_cache ||= MemeCaptain::FilesystemCache.new('img_cache/source')

      processed_id = Digest::SHA1.hexdigest(params.sort.map(&:join).join)
      processed_img_data = @processed_cache.get(processed_id) {
        source_id = Digest::SHA1.hexdigest(params[:u])
        source_img_data = @source_cache.get(source_id) {
          Curl::Easy.perform(params[:u]).body_str
        }
        MemeCaptain.meme(source_img_data, params[:tt], params[:tb]).to_blob {
          self.quality = 100
        }
      }

      headers = {
        'Content-Type' => MemeCaptain.content_type(processed_img_data),
        'ETag' => "\"#{Digest::SHA1.hexdigest(processed_img_data)}\"",
        }

      [ 200, headers, processed_img_data ]
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

  end

end
