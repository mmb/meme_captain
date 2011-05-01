require 'digest/sha1'
require 'uri'

require 'curb'
require 'sinatra/base'

require 'meme_captain'

module MemeCaptain

  class Server < Sinatra::Base

    ImageExts = %w{.jpeg .gif .png}

    get '/' do
      @img_url = if params[:u]
        uri = URI(request.url)
        uri.path += 'i'
        uri.to_s
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
          curl = Curl::Easy.perform(params[:u]) do |c|
            c.useragent = 'Meme Captain http://memecaptain.com/'
          end
          curl.body_str
        }

        meme_img = MemeCaptain.meme(source_img_data, params[:tt], params[:tb])
        current_format = meme_img.format

        meme_img.to_blob {
          self.quality = 100
          # convert non-animated gifs to png
          if current_format == 'GIF' and meme_img.size == 1
            self.format = 'PNG'  
          end
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
