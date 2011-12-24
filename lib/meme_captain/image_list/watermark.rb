require 'RMagick'

module MemeCaptain

  module ImageList

    # Mix-in for Magick::ImageList to add watermark.
    module Watermark

      # Watermark this image using another image.
      def watermark_mc(watermark_img)
        self.each do |frame|
          frame.composite!(watermark_img, Magick::SouthEastGravity,
            -frame.page.width + frame.columns + frame.page.x,
            -frame.page.height + frame.rows + frame.page.y,
            Magick::OverCompositeOp)
        end
      end

    end

  end

end
