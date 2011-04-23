require 'digest/sha1'

require 'curb'
require 'sinatra/base'

require 'meme_captain'

module MemeCaptain

  class Server < Sinatra::Base

    ImageExts = %w{.jpeg .gif .png}

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
      processed_cache_path = @processed_cache.get_path(processed_id, ImageExts) {
        source_id = Digest::SHA1.hexdigest(params[:u])
        source_img_data = @source_cache.get_data(source_id, ImageExts) {
          Curl::Easy.perform(params[:u]).body_str
        }

        MemeCaptain.meme(source_img_data, params[:tt], params[:tb]).to_blob {
          self.quality = 100
        }
      }

      headers = {
        'Content-Type' => MIME::Types.type_for(processed_cache_path)[0].to_s,
        }

      [ 200, headers, MemeCaptain::FileBody.new(processed_cache_path) ]
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

  end

end
