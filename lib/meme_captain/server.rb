require 'digest/sha1'
require 'uri'

require 'curb'
require 'json'
require 'sinatra/base'

require 'meme_captain'

module MemeCaptain

  class Server < Sinatra::Base

    ImageExts = %w{.jpeg .gif .png}

    get '/' do
      @u = params[:u]
      @tt= params[:tt]
      @tb = params[:tb]

      erb :index
    end

    def gen(params)
      @processed_cache ||= MemeCaptain::FilesystemCache.new('public/tmp')
      @source_cache ||= MemeCaptain::FilesystemCache.new('img_cache/source')

      processed_id = Digest::SHA1.hexdigest(params.sort.map(&:join).join)
      @processed_cache.get_path(processed_id, ImageExts) {
        source_id = Digest::SHA1.hexdigest(params[:u])
        source_img_data = @source_cache.get_data(source_id, ImageExts) {
          curl = Curl::Easy.perform(params[:u]) do |c|
            c.useragent = 'Meme Captain http://memecaptain.com/'
          end
          unless curl.response_code == 200
            raise "Error loading source image url #{params[:u]}"
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
    end

    get '/g' do
      begin
        processed_cache_path = gen(params)

        temp_url = URI(request.url)
        temp_url.path = processed_cache_path.sub('public', '')
        temp_url.query = nil

        perm_url = URI(request.url)
        perm_url.path = '/i'

        [200, { 'Content-Type' => 'application/json' }, {
          'tempUrl' => temp_url.to_s,
          'permUrl' => perm_url.to_s,
        }.to_json]
      rescue => error
        [500, { 'Content-Type' => 'text/plain' }, error.to_s]
      end
    end

    get '/i' do
      processed_cache_path = gen(params)

      content_type MIME::Types.type_for(processed_cache_path)[0].to_s

      MemeCaptain::FileBody.new(processed_cache_path)
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

  end

end
