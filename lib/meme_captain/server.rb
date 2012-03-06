require 'digest/sha1'

require 'json'
require 'rack'
require 'sinatra/base'

module MemeCaptain

  class Server < Sinatra::Base

    set :root, File.expand_path(File.join('..', '..'), File.dirname(__FILE__))
    set :source_img_max_side, 800
    set :upload_prefix, 'up/'
    set :watermark, Magick::ImageList.new(File.expand_path(
      File.join('..', '..', 'watermark.png'), File.dirname(__FILE__)))

    # uncomment this to allow other sites to use this site's backend for
    # generating images, used to allow third-party static only sites
    # to generate images using memecaptain.com

    # set :protection, :except => :json_csrf

    get '/' do
      @u = params[:u]

      @t1 = params[:t1]
      @t1x = params[:t1x]
      @t1y = params[:t1y]
      @t1w = params[:t1w]
      @t1h = params[:t1h]

      @t2 = params[:t2]
      @t2x = params[:t2x]
      @t2y = params[:t2y]
      @t2w = params[:t2w]
      @t2h = params[:t2h]

      @root_url = url('/')

      erb :index
    end

    def normalize_params(p)
      result = NormParams.new(p)

      # if the id of an existing meme is passed in as the source url, use the
      # source image of that meme for the source image
      if result.u[%r{^[a-f0-9]+\.(?:gif|jpg|png)$}]
        if existing_as_source = MemeData.find_by_meme_id(result.u)
          result.u = existing_as_source.source_url
        end
      end

      result
    end

    def gen(p)
      logger.debug "params:\n#{MemeCaptain.pretty_format(p)}"
      norm_params = normalize_params(p)
      logger.debug 'normalized params:'
      logger.debug(MemeCaptain.pretty_format(norm_params))

      if existing = MemeData.first(
        :source_url => norm_params.u,

        'texts.0.text' => norm_params.t1,
        'texts.0.x' => norm_params.t1x,
        'texts.0.y' => norm_params.t1y,
        'texts.0.w' => norm_params.t1w,
        'texts.0.h' => norm_params.t1h,

        'texts.1.text' => norm_params.t2,
        'texts.1.x' => norm_params.t2x,
        'texts.1.y' => norm_params.t2y,
        'texts.1.w' => norm_params.t2w,
        'texts.1.h' => norm_params.t2h
        )
        logger.debug 'found existing meme:'
        logger.debug(MemeCaptain.pretty_format(existing))
        existing
      else
        if same_source = MemeData.find_by_source_url(norm_params.u)
          logger.debug 'found existing source image'
          source_fs_path = same_source.source_fs_path
        elsif (norm_params.u.index(settings.upload_prefix) == 0) and
          (upload = Upload.find_by_upload_id(
          norm_params.u[settings.upload_prefix.size..-1]))

          logger.debug 'source image is upload:'
          logger.debug MemeCaptain.pretty_format(upload)
          source_fs_path = upload.fs_path
        else
          if source_fetch_fail = SourceFetchFail.find_by_url(norm_params.u)
            logger.debug 'skipping fetch of previously failed source image:'
            logger.debug(MemeCaptain.pretty_format(source_fetch_fail))
            source_fetch_fail.requested!
            halt 500, 'Error loading source image url'
          else
            source_img = ImageList::SourceImage.new
            begin
              logger.debug "fetch source image: #{norm_params.u}"
              source_img.fetch! norm_params.u
            rescue => error
              new_source_fetch_fail = SourceFetchFail.new(
                :attempt_count => 1,
                :orig_ip => request.ip,
                :response_code => error.respond_to?(:response_code) ?
                  error.response_code : nil,
                :url => norm_params.u
              )
              logger.debug 'source image fetch failed:'
              logger.debug(MemeCaptain.pretty_format(new_source_fetch_fail))
              new_source_fetch_fail.save!
              halt 500, 'Error loading source image url'
            end
            source_img.prepare! settings.source_img_max_side, settings.watermark
            source_fs_path = source_img.cache(norm_params.u, 'source_cache')
            source_img.each { |frame| frame.destroy! }
          end
        end

        logger.debug "source image filesystem path: #{source_fs_path}"

        open(source_fs_path, 'rb') do |source_io|
          t1 = TextPos.new(norm_params.t1, norm_params.t1x, norm_params.t1y,
            norm_params.t1w, norm_params.t1h)

          t2 = TextPos.new(norm_params.t2, norm_params.t2x, norm_params.t2y,
            norm_params.t2w, norm_params.t2h)

          meme_img = MemeCaptain.meme(source_io, [t1, t2])
          meme_img.extend ImageList::Cache

          # convert source images in formats other than jpeg, gif or png
          # to png
          unless %w{JPEG GIF PNG}.include?(meme_img.format)
            meme_img.format = 'PNG'
          end

          # convert non-animated gifs to png
          if meme_img.format == 'GIF' and meme_img.size == 1
            meme_img.format = 'PNG'
          end

          sig = norm_params.signature
          meme_hash = Digest::SHA1.hexdigest(sig)

          meme_id = nil
          (6..meme_hash.size).each do |len|
            meme_id = "#{meme_hash[0,len]}.#{meme_img.extension}"
            break  unless MemeData.where(:meme_id => meme_id).count > 0
          end

          meme_fs_path = meme_img.cache(sig, File.join('public', 'meme'))

          logger.debug "meme filesystem path: #{meme_fs_path}"

          meme_img.write(meme_fs_path) {
            self.quality = 100
          }

          meme_data = MemeData.new(
            :meme_id => meme_id,
            :fs_path => meme_fs_path,
            :mime_type => meme_img.mime_type,
            :size => File.size(meme_fs_path),

            :source_url => norm_params.u,
            :source_fs_path => source_fs_path,

            :texts => [{
              :text => norm_params.t1,
              :x => norm_params.t1x,
              :y => norm_params.t1y,
              :w => norm_params.t1w,
              :h => norm_params.t1h,
              }, {
              :text => norm_params.t2,
              :x => norm_params.t2x,
              :y => norm_params.t2y,
              :w => norm_params.t2w,
              :h => norm_params.t2h,
            }],

            :request_count => 0,

            :creator_ip => request.ip
            )

          meme_img.each { |frame| frame.destroy! }

          logger.debug "meme data:\n#{MemeCaptain.pretty_format(meme_data)}"

          meme_data.save! :safe => true

          meme_data
        end

      end
    end

    get '/g' do
      begin
        meme_data = gen(params)

        [200, { 'Content-Type' => 'application/json' }, {
          'imageUrl' => url("/#{meme_data.meme_id}"),
          'templateUrl' => url("/?u=#{Rack::Utils.escape(meme_data.meme_id)}"),
        }.to_json]
      rescue => error
        logger.error "error generating image: #{error.class} #{error.message}"
        logger.error(MemeCaptain.pretty_format(error.backtrace))
        [500, { 'Content-Type' => 'text/plain' }, 'Error generating image']
      end
    end

    def serve_img(meme_data)
      meme_data.requested!

      send_file meme_data.fs_path, :type => meme_data.mime_type
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

    post '/upload' do
      redirect('/')  unless params[:upload]

      img = ImageList::SourceImage.new
      img.from_blob(params[:upload][:tempfile].read)
      img.prepare! settings.source_img_max_side, settings.watermark
      fs_path = img.cache(params[:upload][:filename], 'source_cache')

      filename_hash = Digest::SHA1.hexdigest(params[:upload][:filename])

      len = 6
      upload_id = filename_hash[0,len]
      while Upload.where(:upload_id => upload_id).count > 0
        upload_id = if len < filename_hash.size
          len += 1
          filename_hash[0,len]
        else
          "#{upload_id}0"
        end
      end

      upload = Upload.new(
        :upload_id => upload_id,
        :fs_path => fs_path,
        :mime_type => img.mime_type,
        :size => File.size(fs_path),
        :request_count => 0,
        :creator_ip => request.ip
        )

      img.each { |frame| frame.destroy! }

      upload.save! :safe => true

      redirect "/?u=#{settings.upload_prefix}#{Rack::Utils.escape(upload_id)}"
    end

    get %r{/#{settings.upload_prefix}(.+)} do
      if upload = Upload.find_by_upload_id(params[:captures][0])
        serve_img upload
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
