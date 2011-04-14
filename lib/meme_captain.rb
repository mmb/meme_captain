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

      cur_pointsize -= 1

      self.pointsize = cur_pointsize
      set_stroke_width(cur_pointsize)
    end

    # Set stroke width based on point size.
    def set_stroke_width(pointsize)
      self.stroke_width = pointsize > 30 ? 2 : 1
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

  def meme(path_or_io, line1, line2, draw_options={})
    draw_options = {
      :fill => 'white',
      :font => 'Impact-Regular',
      :stroke => 'black',
      }.merge(draw_options)

    line1 = word_wrap(line1.upcase)
    line2 = word_wrap(line2.upcase)

    text = Magick::Draw.new {
      draw_options.each { |k,v| self.send("#{k}=", v) }
    }

    text.extend(MemeCaptain::Draw)

    img = Magick::ImageList.new
    if path_or_io.respond_to?(:read)
      img.from_blob(path_or_io.read)
    else
      img.read(path_or_io)
    end

    max_text_height = img.rows / 4

    text.set_point_size(line1, img.columns, max_text_height)

    text.annotate(img, 0, 0, 0, 0, line1) {
      self.gravity = Magick::NorthGravity
    }

    text.set_point_size(line2, img.columns, max_text_height)

    text.annotate(img, 0, 0, 0, 0, line2) {
      self.gravity = Magick::SouthGravity
    }

    img
  end

end

