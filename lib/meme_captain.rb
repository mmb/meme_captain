require 'RMagick'

module MemeCaptain

  module Draw

    # Set the largest point size so that text will fit in max_x, max_y.
    def set_point_size(text, max_x, max_y, min_pointsize=24)
      cur_pointsize = min_pointsize
      self.pointsize = cur_pointsize
      metrics = get_multiline_type_metrics(text)

      while metrics.width < max_x and metrics.height < max_y
        cur_pointsize += 1
        self.pointsize = cur_pointsize
        metrics = get_multiline_type_metrics(text)
      end

      self.pointsize = cur_pointsize - 1
    end

  end

  module_function

  # Wrap a string into len length lines.
  def word_wrap(text, len=40)
    # Adapted from Rails.
    text.split("\n").map do |line|
      line.length > len ? line.gsub(
        /(.{1,#{len}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end

  def meme(path_or_io, line1, line2)
    line1 = word_wrap(line1.upcase)
    line2 = word_wrap(line2.upcase)

    text1 = Magick::Draw.new {
      self.fill = 'white'
      self.font = 'Impact-Regular'
      self.stroke = 'black'
      self.stroke_width = 2
    }
    text1.extend(MemeCaptain::Draw)

    img = Magick::ImageList.new
    if path_or_io.respond_to?(:read)
      img.from_blob(path_or_io.read)
    else
      img.read(path_or_io)
    end

    text1.set_point_size(line1, img.columns, img.rows / 4)

    text1.annotate(img, 0, 0, 0, 0, line1) {
      self.gravity = Magick::NorthGravity
    }

    text2 = Magick::Draw.new {
      self.fill = 'white'
      self.font = 'Impact-Regular'
      self.stroke = 'black'
      self.stroke_width = 2
    }
    text2.extend(MemeCaptain::Draw)

    text2.set_point_size(line2, img.columns, img.rows / 4)

    text2.annotate(img, 0, 0, 0, 0, line2) {
      self.gravity = Magick::SouthGravity
    }

    img
  end

end
