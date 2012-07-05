module MemeCaptain

  # Mix-in for Magick::Draw
  module Draw

    # Calculate the largest pointsize for text that will be in a width x
    # height box.
    #
    # Return [pointsize, metrics] where pointsize is the largest pointsize and
    # metrics is the RMagick multiline type metrics of the best fit.
    def calc_pointsize(width, height, text, min_pointsize)
      current_pointsize = min_pointsize

      metrics = nil

      loop {
        self.pointsize = current_pointsize
        last_metrics = metrics
        metrics = get_multiline_type_metrics(text)

        if metrics.width + stroke_padding > width or
          metrics.height + stroke_padding > height
          if current_pointsize > min_pointsize
            current_pointsize -= 1
            metrics = last_metrics
          end
          break
        else
          current_pointsize += 1
        end
      }

      [current_pointsize, metrics]
    end

    # Return the number of pixels of padding to account for this object's
    # stroke width.
    def stroke_padding
      # Each side of the text needs stroke_width / 2 pixels of padding
      # because half of the stroke goes inside the text and half goes
      # outside. The / 2 and * 2 (each side) cancel.
      @stroke_width.to_i
    end

    # Override and set instance variable because there is apparently no way to
    # get the value of a Draw's current stroke width.
    def stroke_width=(stroke_width)
      @stroke_width = stroke_width
      super
    end

  end

end
