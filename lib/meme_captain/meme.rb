require 'RMagick'

module MemeCaptain

  module_function

  # Create a meme image.
  # Input can be an IO object or a blob of data.
  def meme(input, top_text, bottom_text, options={})
    img = Magick::ImageList.new
    if input.respond_to?(:read)
      img.from_blob(input.read)
    else
      img.from_blob(input)
    end

    super_sample = 2.0

    min_pointsize = 12 * super_sample
    text_width = img.page.width * 0.9 * super_sample
    text_height = img.page.height / 4.0 * super_sample

    text_layer = Magick::Image.new(
      img.page.width * super_sample, img.page.height * super_sample) {
      self.background_color = 'none'
      self.density = 144
    }

    draw = Magick::Draw.new.extend(Draw)

    draw.fill = 'white'
    draw.font = 'Impact'

    top_text_upper = top_text.to_s.upcase

    unless top_text_upper.empty?
      max_pointsize = nil
      top_text_choice = top_text_upper

      (1..3).each do |num_lines|
        text = word_wrap(top_text_upper, num_lines)
        pointsize = draw.calc_pointsize(
          text_width, text_height, text, min_pointsize)
        if max_pointsize.nil? or pointsize > max_pointsize
          max_pointsize = pointsize
          top_text_choice = text
        end
      end

      draw.gravity = Magick::NorthGravity
      draw.pointsize = max_pointsize

      draw.stroke = 'black'
      draw.stroke_width = 4
      draw.annotate(text_layer, 0, 0, 0, 0, top_text_choice)

      draw.stroke = 'none'
      draw.annotate(text_layer, 0, 0, 0, 0, top_text_choice)
    end

    bottom_text_upper = bottom_text.to_s.upcase

    unless bottom_text_upper.empty?
      max_pointsize = nil
      bottom_text_choice = bottom_text_upper

      (1..3).each do |num_lines|
        text = word_wrap(bottom_text_upper, num_lines)
        pointsize = draw.calc_pointsize(
          text_width, text_height, text, min_pointsize)
        if max_pointsize.nil? or pointsize > max_pointsize
          max_pointsize = pointsize
          bottom_text_choice = text
        end
      end

      draw.gravity = Magick::SouthGravity
      draw.pointsize = max_pointsize

      draw.stroke = 'black'
      draw.stroke_width = 4
      draw.annotate(text_layer, 0, 0, 0, 0, bottom_text_choice)

      draw.stroke = 'none'
      draw.annotate(text_layer, 0, 0, 0, 0, bottom_text_choice)
    end

    text_layer.resize!(1 / super_sample)

    img.each do |frame|
      frame.composite!(text_layer, -frame.page.x, -frame.page.y,
        Magick::OverCompositeOp)
      frame.strip!
    end
    img

  end

end
