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

        if metrics.width > width or metrics.height > height
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

  end

end
