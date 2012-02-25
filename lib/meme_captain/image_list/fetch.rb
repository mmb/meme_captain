require 'curb'

module MemeCaptain

  module ImageList

    # Mix-in for Magick::ImageList to add loading from a URL.
    module Fetch

      # Load this image from a URL.
      def fetch!(url)
        curl = Curl::Easy.perform(url) do |c|
          c.useragent = 'Meme Captain http://memecaptain.com/'
          c.follow_location = true
          c.max_redirects = 3
        end
        unless curl.response_code == 200
          raise FetchError.new(curl.response_code)
        end

        from_blob curl.body_str
      end
      
    end

  end

end
