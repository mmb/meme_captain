module MemeCaptain

  # Mix-in for Magick::Draw
  module Draw

    # Calculate the largest pointsize for text that will be in a width x
    # height box.
    #
    # Return [pointsize, fits] where pointsize is the largest pointsize and
    # fits is true if that pointsize will fit in the box.
    def calc_pointsize(width, height, text, min_pointsize)
      current_pointsize = min_pointsize

      fits = false

      loop {
        self.pointsize = current_pointsize
        metrics = get_multiline_type_metrics(text)
        if metrics.width > width or metrics.height > height
          if current_pointsize > min_pointsize
            current_pointsize -= 1
            fits = true
          end
          break
        else
          current_pointsize += 1
        end
      }

      [current_pointsize, fits]
    end

  end

end
