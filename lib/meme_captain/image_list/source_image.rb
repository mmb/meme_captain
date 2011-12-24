require 'RMagick'

module MemeCaptain

  module ImageList

    # Source image for meme generation.
    class SourceImage < Magick::ImageList
      include Cache
      include Fetch
      include Watermark

      # Shrink image if necessary and add watermark.
      def prepare!(max_side, watermark_img)
        if size == 1 and (columns > max_side or rows > max_side)
          resize_to_fit! max_side
        end

        watermark_mc watermark_img

        strip!
      end

    end

  end

end
