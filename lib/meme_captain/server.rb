require 'digest/sha1'

require 'json'
require 'rack'
require 'sinatra/base'

module MemeCaptain

  class Server < Sinatra::Base

    set :root, File.expand_path(File.join('..', '..'), File.dirname(__FILE__))
    set :source_img_max_side, 800
    set :watermark, Magick::ImageList.new(File.expand_path(
      File.join('..', '..', 'watermark.png'), File.dirname(__FILE__)))

    get '/' do
      @u = params[:u]
      @tt= params[:tt]
      @tb = params[:tb]

      @root_url = url('/')

      erb :index
    end

    def normalize_params(p)
      result = {
        'u' => p[:u],
         # convert to empty string if null
        'tt' => p[:tt].to_s,
        'tb' => p[:tb].to_s,
      }

      # if the id of an existing meme is passed in as the source url, use the
      # source image of that meme for the source image
      if result['u'][%r{^[a-f0-9]+\.(?:gif|jpg|png)$}]
        if existing_as_source = MemeData.find_by_meme_id(result['u'])
          result['u'] = existing_as_source.source_url
        end
      end

      # hash with string keys that can be accessed by symbol
      Hash.new { |hash,key| hash[key.to_s] if Symbol === key }.merge(result)
    end

    def gen(p)
      norm_params = normalize_params(p)

      if existing = MemeData.first(
        :source_url => norm_params[:u],
        :top_text => norm_params[:tt],
        :bottom_text => norm_params[:tb]
        )
        existing
      else
        if same_source = MemeData.find_by_source_url(norm_params[:u])
          source_fs_path = same_source.source_fs_path
        else
          source_img = ImageList::SourceImage.new
          source_img.fetch! norm_params[:u]
          source_img.prepare! settings.source_img_max_side, settings.watermark
          source_fs_path = source_img.cache(norm_params[:u], 'source_cache')
        end

        open(source_fs_path, 'rb') do |source_io|
          meme_img = MemeCaptain.meme(source_io, norm_params[:tt],
            norm_params[:tb])
          meme_img.extend ImageList::Cache

          # convert non-animated gifs to png
          if meme_img.format == 'GIF' and meme_img.size == 1
            meme_img.format = 'PNG'
          end

          params_s = norm_params.sort.map(&:join).join
          meme_hash = Digest::SHA1.hexdigest(params_s)

          meme_id = nil
          (6..meme_hash.size).each do |len|
            meme_id = "#{meme_hash[0,len]}.#{meme_img.extension}"
            break  unless MemeData.where(:meme_id => meme_id).count > 0
          end

          meme_fs_path = meme_img.cache(params_s, File.join('public', 'meme'))

          meme_img.write(meme_fs_path) {
            self.quality = 100
          }

          meme_data = MemeData.new(
            :meme_id => meme_id,
            :fs_path => meme_fs_path,
            :mime_type => meme_img.mime_type,
            :size => File.size(meme_fs_path),

            :source_url => norm_params[:u],
            :source_fs_path => source_fs_path,
            :top_text => norm_params[:tt],
            :bottom_text => norm_params[:tb],

            :request_count => 0,

            :creator_ip => request.ip
            )

          meme_data.save! :safe => true

          meme_data
        end

      end
    end

    get '/g' do
      raise Sinatra::NotFound  if params[:u].to_s.empty?

      begin
        meme_data = gen(params)

        meme_url = url("/#{meme_data.meme_id}")

        template_query = [
          [:u, meme_data.meme_id],
          [:tt, meme_data.top_text],
          [:tb, meme_data.bottom_text],
          ].map { |k,v|
            "#{Rack::Utils.escape(k)}=#{Rack::Utils.escape(v)}" }.join('&')

        [200, { 'Content-Type' => 'application/json' }, {
          'tempUrl' => meme_url,
          'permUrl' => meme_url,
          'templateUrl' => url("/?#{template_query}"),
        }.to_json]
      rescue => error
        [500, { 'Content-Type' => 'text/plain' }, error.to_s]
      end
    end

    def serve_img(meme_data)
      meme_data.requested!

      content_type meme_data.mime_type

      FileBody.new meme_data.fs_path
    end

    get '/i' do
      raise Sinatra::NotFound  if params[:u].to_s.empty?

      serve_img(gen(params))
    end

    get %r{^/([a-f0-9]+\.(?:gif|jpg|png))$} do
      if meme_data = MemeData.find_by_meme_id(params[:captures][0])
        serve_img meme_data
      else
        raise Sinatra::NotFound
      end
    end

    not_found do
      @root_url = url('/')

      erb :'404'
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

  end

end
