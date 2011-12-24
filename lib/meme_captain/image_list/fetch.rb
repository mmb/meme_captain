require 'curb'

module MemeCaptain

  module ImageList

    # Mix-in for Magick::ImageList to add loading from a URL.
    module Fetch

      # Load this image from a URL.
      def fetch!(url)
        curl = Curl::Easy.perform(url) do |c|
          c.useragent = 'Meme Captain http://memecaptain.com/'
        end
        unless curl.response_code == 200
          raise "Error loading source image url #{params[:u]}"
        end

        from_blob curl.body_str
      end
      
    end

  end

end
