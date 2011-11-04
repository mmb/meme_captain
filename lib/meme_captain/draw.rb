module MemeCaptain

  # Mix-in for Magick::Draw
  module Draw

    # Calculate the largest pointsize for text that will fit in width x height.
    def calc_pointsize(width, height, text, min_pointsize)
      current_pointsize = min_pointsize

      loop {
        self.pointsize = current_pointsize
        metrics = get_multiline_type_metrics(text)
        if metrics.width > width or metrics.height > height
          if current_pointsize > min_pointsize
            current_pointsize -= 1
          end
          break
        else
          current_pointsize += 1
        end
      }

      current_pointsize
    end

  end

end
