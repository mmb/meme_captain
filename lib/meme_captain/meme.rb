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

    max_lines = 16
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

    [
      [Caption.new(top_text), Magick::NorthGravity],
      [Caption.new(bottom_text), Magick::SouthGravity],
    ].select { |x| x[0].drawable? }.each do |caption, gravity|
      wrap_tries = (1..max_lines).map { |num_lines|
        caption.wrap(num_lines).upcase.annotate_quote
      }.uniq

      choices = wrap_tries.map do |wrap_try|
        pointsize, fits = draw.calc_pointsize(
          text_width, text_height, wrap_try, min_pointsize)

        CaptionChoice.new(fits, pointsize, wrap_try)
      end

      choice = choices.max

      draw.gravity = gravity
      draw.pointsize = choice.pointsize

      draw.stroke = 'black'
      draw.stroke_width = 8
      draw.annotate text_layer, 0, 0, 0, 0, choice.text

      draw.stroke = 'none'
      draw.annotate text_layer, 0, 0, 0, 0, choice.text
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
