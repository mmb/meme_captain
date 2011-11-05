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

    top_caption = Caption.new(top_text)

    if top_caption.drawable?
      max_pointsize = nil
      wrap_choice = nil

      (1..3).each do |num_lines|
        wrap_try = top_caption.wrap(num_lines).upcase.annotate_quote
        pointsize = draw.calc_pointsize(
          text_width, text_height, wrap_try, min_pointsize)
        if max_pointsize.nil? or pointsize > max_pointsize
          max_pointsize = pointsize
          wrap_choice = wrap_try
        end
      end

      draw.gravity = Magick::NorthGravity
      draw.pointsize = max_pointsize

      draw.stroke = 'black'
      draw.stroke_width = 8
      draw.annotate text_layer, 0, 0, 0, 0, wrap_choice

      draw.stroke = 'none'
      draw.annotate text_layer, 0, 0, 0, 0, wrap_choice
    end

    bottom_caption = Caption.new(bottom_text)

    if bottom_caption.drawable?
      max_pointsize = nil
      wrap_choice = nil

      (1..3).each do |num_lines|
        wrap_try = bottom_caption.wrap(num_lines).upcase.annotate_quote
        pointsize = draw.calc_pointsize(
          text_width, text_height, wrap_try, min_pointsize)
        if max_pointsize.nil? or pointsize > max_pointsize
          max_pointsize = pointsize
          wrap_choice = wrap_try
        end
      end

      draw.gravity = Magick::SouthGravity
      draw.pointsize = max_pointsize

      draw.stroke = 'black'
      draw.stroke_width = 8
      draw.annotate text_layer, 0, 0, 0, 0, wrap_choice

      draw.stroke = 'none'
      draw.annotate text_layer, 0, 0, 0, 0, wrap_choice
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
