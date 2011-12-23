require 'digest/sha1'
require 'fileutils'
require 'uri'

require 'curb'
require 'json'
require 'mongo'
require 'RMagick'
require 'sinatra/base'

module MemeCaptain

  class Server < Sinatra::Base

    SourceImageMaxSide = 800

    set :root, File.expand_path(File.join('..', '..'), File.dirname(__FILE__))

    set :db, Mongo::Connection.new.db('memecaptain')

    get '/' do
      @u = params[:u]
      @tt= params[:tt]
      @tb = params[:tb]

      erb :index
    end

    def gen(params)
      meme_collection = settings.db['meme']

      if existing = meme_collection.find_one(
        'source_url' => params[:u],
        'top_text' => params[:tt],
        'bottom_text' => params[:tb]
        )
        existing
      else
        if same_source = meme_collection.find_one(
          'source_url' => params[:u]
          )
          source_fs_path = same_source['source_fs_path']
        else
          curl = Curl::Easy.perform(params[:u]) do |c|
            c.useragent = 'Meme Captain http://memecaptain.com/'
          end
          unless curl.response_code == 200
            raise "Error loading source image url #{params[:u]}"
          end

          # shrink large source images
          source_img = Magick::ImageList.new.from_blob(curl.body_str)
          if source_img.size == 1 and
            (source_img.columns > SourceImageMaxSide or
            source_img.rows > SourceImageMaxSide)
            source_img.resize_to_fit! SourceImageMaxSide
          end

          @watermark ||= Magick::ImageList.new(
            File.join(settings.root, 'watermark.png'))
          source_img.extend MemeCaptain::Watermark
          source_img.watermark_mc @watermark

          source_img.strip!

          source_hash = Digest::SHA1.hexdigest(params[:u])

          source_dir = File.join('source_cache', source_hash[0,3])
          FileUtils.mkdir_p source_dir

          source_ext = MemeCaptain.mime_type_ext(source_img.mime_type)

          source_fs_path = File.join(source_dir,
            "#{source_hash[3..-1]}.#{source_ext}")

          source_img.write(source_fs_path) {
            self.quality = 100
          }
        end

        open(source_fs_path, 'rb') do |source_io|
          meme_img = MemeCaptain.meme(source_io, params[:tt], params[:tb])

          # convert non-animated gifs to png
          if meme_img.format == 'GIF' and meme_img.size == 1
            meme_format = 'PNG'
            meme_mime_type = 'image/png'
          else
            meme_format = meme_img.format
            meme_mime_type = meme_img.mime_type
          end

          meme_ext = MemeCaptain.mime_type_ext(meme_mime_type)

          meme_hash = Digest::SHA1.hexdigest(params.sort.map(&:join).join)

          meme_id = nil
          (6..meme_hash.size).each do |len|
            meme_id = "#{meme_hash[0,len]}.#{meme_ext}"
            break  unless meme_collection.find_one('meme_id' => meme_id)
          end

          meme_fs_dir = File.join('public', 'meme', meme_id[0,3])
          FileUtils.mkdir_p meme_fs_dir

          meme_fs_path = File.join(meme_fs_dir, meme_id[3..-1])

          meme_img.write(meme_fs_path) {
            self.format = meme_format
            self.quality = 100
          }

          now = Time.now

          meme_data = {
            'meme_id' => meme_id,
            'fs_path' => meme_fs_path,
            'mime_type' => meme_mime_type,

            'source_url' => params[:u],
            'source_fs_path' => source_fs_path,
            'top_text' => params[:tt],
            'bottom_text' => params[:tb],

            'request_count' => 0,
            'last_request' => now,

            'created' => now,
            'creator_ip' => request.ip,
            }

          meme_collection.insert meme_data

          meme_data
        end

      end
    end

    get '/g' do
      begin
        meme_data = gen(params)

        meme_url = URI(request.url)
        meme_url.path = "/#{meme_data['meme_id']}"
        meme_url.query = nil

        hackable_url = URI(request.url)
        hackable_url.path = '/i'

        meme_url_s = meme_url.to_s

        [200, { 'Content-Type' => 'application/json' }, {
          'tempUrl' => meme_url_s,
          'permUrl' => meme_url_s,
          'hackableUrl' => hackable_url.to_s,
        }.to_json]
      rescue => error
        [500, { 'Content-Type' => 'text/plain' }, error.to_s]
      end
    end

    def request_update(meme_id)
      settings.db['meme'].update(
        { 'meme_id' => meme_id },
        {
          '$inc' => { 'request_count' => 1 },
          '$set' => { 'last_request' => Time.now },
        }
      )
    end

    def serve_meme_data(meme_data)
      request_update meme_data['meme_id']

      content_type meme_data['mime_type']

      FileBody.new meme_data['fs_path']
    end

    get '/i' do
      serve_meme_data(gen(params))
    end

    get %r{^/([a-f0-9]+\.(?:gif|jpg|png))$} do
      if meme_data = settings.db['meme'].find_one(
        'meme_id' => params[:captures][0])
        serve_meme_data(meme_data)
      else
        [404, 'not found']
      end
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

  end

end
